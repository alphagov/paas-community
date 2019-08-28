require 'aws-sdk-s3'
require 'cf-app-utils'
require 'securerandom'
require 'sinatra'

set :environment, ENV.fetch('RACK_ENV', 'development')
set :port, ENV.fetch('PORT', '9292').to_i
set :sessions, true

Pothole = Struct.new(:guid, :url)

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

def potholes
  s3
    .list_objects(bucket: bucket_name)
    .contents
    .map { |o| Pothole.new(o.key.sub(/[.]jpg$/, ''), image_url(o.key)) }
end

get '/healthcheck' do
  'ok'
end

before do
  @message = session.delete(:message) if session[:message]
end

get '/' do
  @potholes = potholes
  erb :index
end

post '/' do
  addr = params[:'pothole-address']
  file = params[:'pothole-image']

  if addr.nil? || file.nil? || addr.empty? || file.empty?
    @potholes = potholes
    @error = 'Please enter an address and upload an image'
    erb :index
  else
    File.open(file[:tempfile], 'rb') do |f|
      key = "#{SecureRandom.uuid}.jpg"
      s3.put_object(bucket: bucket_name, key: key, body: f)
    end

    session[:message] = 'Pothole report uploaded successfully, thank you.'
    redirect '/'
  end
end
