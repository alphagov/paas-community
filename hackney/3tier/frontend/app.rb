require 'aws-sdk-s3'
require 'cf-app-utils'
require 'http'
require 'json'
require 'securerandom'
require 'sinatra'

set :environment, ENV.fetch('RACK_ENV', 'development')
set :port, ENV.fetch('PORT', '9292').to_i
set :sessions, true

API_URL = ENV.fetch('API_URL')

Pothole = Struct.new(:guid, :address, :url)

def creds
  CF::App::Credentials.find_by_service_label('aws-s3-bucket')
end

def bucket_name
  creds['bucket_name']
end

def bucket_region
  creds['aws_region']
end

def s3
  Aws::S3::Client.new(
    access_key_id: creds['aws_access_key_id'],
    secret_access_key: creds['aws_secret_access_key'],
    region: bucket_region
  )
end

def image_url(key)
  "https://#{bucket_name}.s3-#{bucket_region}.amazonaws.com/#{key}"
end

def fetch_potholes
  url = "#{API_URL}/potholes"

  response = HTTP.get(url)

  potholes = JSON.parse(response.body.to_s)

  potholes.map do |p|
    Pothole.new(
      p.fetch('id'),
      p.fetch('address'),
      "#{image_url(p.fetch('id'))}.jpg"
    )
  end
end

def create_pothole(guid, address)
  url = "#{API_URL}/potholes"

  HTTP.post(url, json: {
    address: address,
    guid: guid
  })
end

get '/healthcheck' do
  'ok'
end

before do
  @message = session.delete(:message) if session[:message]
end

get '/' do
  @potholes = fetch_potholes
  erb :index
end

post '/' do
  addr = params[:'pothole-address']
  file = params[:'pothole-image']

  if addr.nil? || file.nil? || addr.empty? || file.empty?
    @potholes = fetch_potholes
    @error = 'Please enter an address and upload an image'
    erb :index
  else
    guid = SecureRandom.uuid

    File.open(file[:tempfile], 'rb') do |f|
      s3.put_object(bucket: bucket_name, key: "#{guid}.jpg", body: f)
    end

    create_pothole(guid, addr)

    session[:message] = 'Pothole report uploaded successfully, thank you.'
    redirect '/'
  end
end
