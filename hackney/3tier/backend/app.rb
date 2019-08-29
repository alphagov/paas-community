require 'active_record'
require 'cf-app-utils'
require 'json'
require 'securerandom'
require 'sinatra'

def database_uri
  if ENV.key? 'VCAP_SERVICES'
    CF::App::Credentials.find_by_service_label('postgres')['uri']
  else
    ENV.fetch('DATABASE_URI')
  end
end

ActiveRecord::Base.establish_connection(database_uri)

ActiveRecord::Schema.define(version: 0) do
  create_table 'potholes', id: :string, force: true do |t|
    t.string 'address'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end
end

class Pothole < ActiveRecord::Base
  self.table_name = :potholes

  alias_attribute :guid, :id
end

set :environment, ENV.fetch('RACK_ENV', 'development')
set :port, ENV.fetch('PORT', '9292').to_i
set :sessions, true

get '/potholes' do
  Pothole.all.to_json
end

post '/potholes' do
  body = JSON.parse(request.body.read)
  address = body.fetch('address')
  guid = body.fetch('guid')

  raise 'No address' if address.empty?
  raise 'No guid' if guid.empty?

  pothole = Pothole.new
  pothole.guid = guid
  pothole.address = address
  pothole.save!

  'ok'
end
