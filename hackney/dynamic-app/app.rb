require 'webrick'

server = WEBrick::HTTPServer.new(
  :Port => (ENV['PORT'] || '8080').to_i
)

server.mount_proc "/" do |req, res|
  puts req
  res.body = 'hello'
  res.status = 200
end

server.start