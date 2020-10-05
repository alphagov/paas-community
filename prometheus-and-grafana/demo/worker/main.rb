require "json"
require "redis"
require "httparty"
require 'prometheus_exporter'
require 'prometheus_exporter/server'
# client allows instrumentation to send info to server
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'

server = PrometheusExporter::Server::WebServer.new bind: '0.0.0.0', port: 8080
server.start
PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)
PrometheusExporter::Instrumentation::Process.start(type: "worker")

VCAP_APPLICATION = JSON.parse(ENV["VCAP_APPLICATION"])
APPLICATION_GUID = VCAP_APPLICATION["application_id"]
VCAP_SERVICES = JSON.parse(ENV["VCAP_SERVICES"])
REDIS_CREDENTIALS = VCAP_SERVICES["redis"][0]["credentials"]
REDIS = Redis.new(:url => REDIS_CREDENTIALS["uri"])
AUTOSCALER_CREDENTIALS = VCAP_SERVICES["autoscaler"][0]["credentials"]
AUTOSCALER_URL = AUTOSCALER_CREDENTIALS["custom_metrics"]["url"]
AUTOSCALER_USERNAME = AUTOSCALER_CREDENTIALS["custom_metrics"]["username"]
AUTOSCALER_PASSWORD = AUTOSCALER_CREDENTIALS["custom_metrics"]["password"]
AUTOSCALER_CUSTOM_METRIC_SUBMISSION_URL = "#{AUTOSCALER_URL}/v1/apps/#{APPLICATION_GUID}/metrics"

submissions_processed = PrometheusExporter::Metric::Counter.new("submissions_processed", "how many submissions the worker has processed from Redis")
submissions_in_queue = PrometheusExporter::Metric::Gauge.new("submissions_in_queue", "how many submissions are waiting in Redis")
server.collector.register_metric(submissions_processed)
server.collector.register_metric(submissions_in_queue)

i = -1
loop do
  i += 1

  if i % 1000 == 0
    number_of_submissions_in_queue = REDIS.llen("submissions")
    submissions_in_queue.observe(number_of_submissions_in_queue)

    begin
      resp = HTTParty.post(AUTOSCALER_CUSTOM_METRIC_SUBMISSION_URL, body: {
        instance_index: ENV["CF_INSTANCE_INDEX"].to_i,
        metrics: [{
          name: "submissions_in_queue",
          value: number_of_submissions_in_queue.to_s.to_i
        }]
      }.to_json, :basic_auth => {username: AUTOSCALER_USERNAME, password: AUTOSCALER_PASSWORD})
      throw "Unexpected response code from backend #{resp.code} with body: '#{resp.body}'" if resp.code != 200
      puts "Filed scheduled metrics: #{number_of_submissions_in_queue} submissions in queue"
    rescue Exception => e
      puts "Error submitting custom metric 'submissions_in_queue' to the autoscaler: #{e.message}"
    end
  end

  begin
    item = REDIS.lpop("submissions")
  rescue Exception => e
    puts "Error: #{e.message}"
    STDOUT.flush
    next
  end

  unless item.nil?
    submissions_processed.observe(1)
    sleep 0.1
  end
end
