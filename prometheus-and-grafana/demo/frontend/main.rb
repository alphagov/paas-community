require "sinatra"
require "httparty"
require 'prometheus/client'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

BACKEND_URL = ENV["BACKEND_URL"]
BACKEND_SUBMISSIONS_URL = "#{BACKEND_URL}/submissions"

prometheus = Prometheus::Client.registry
submissions_received = prometheus.counter(:submissions_received, docstring: 'how many submissions the app has received')
submissions_forwarded = prometheus.counter(:submissions_forwarded, docstring: 'how many submissions the app successfully forwarded')
submissions_errored = prometheus.counter(:submissions_errored, docstring: 'how many submissions the app errored and was unable to forward')

get "/" do
   "Hello world"
end

post "/submit" do
    submissions_received.increment
    begin
        resp = HTTParty.post(BACKEND_SUBMISSIONS_URL, body: {message: params['message']})
        throw "Unexpected response code from backend: #{resp.code}" if resp.code != 200
        submissions_forwarded.increment
        "Success: #{resp.body}"
    rescue Exception => e
        submissions_errored.increment
        "Failure: #{e.message}"
    end
end
