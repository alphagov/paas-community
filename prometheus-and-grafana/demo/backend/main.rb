require "json"
require "redis"
require "sinatra"
require "httparty"
require 'prometheus/client'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

VCAP_SERVICES = JSON.parse(ENV["VCAP_SERVICES"])
REDIS_CREDENTIALS = VCAP_SERVICES["redis"][0]["credentials"]
REDIS = Redis.new(:url => REDIS_CREDENTIALS["uri"])

prometheus = Prometheus::Client.registry
submissions_received = prometheus.counter(:submissions_received, docstring: 'how many submissions the app has received')
submissions_queued = prometheus.counter(:submissions_forwarded, docstring: 'how many submissions the app successfully put on the queue')
submissions_errored = prometheus.counter(:submissions_errored, docstring: 'how many submissions the app errored and was unable to enqueue')

get "/" do
   "Hello world"
end

post "/submissions" do
  submissions_received.increment
  begin
    REDIS.rpush("submissions", {message: params[:message]}.to_json)
    submissions_queued.increment
    "Success"
  rescue Exception => e
    submissions_errored.increment
    puts e.inspect
    e.message
  end
end
