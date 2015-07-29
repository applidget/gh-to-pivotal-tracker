require 'sinatra'
require "multi_json"
re

configure do
  # logging is enabled by default in classic style applications,
  # so `enable :logging` is not needed
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

helpers do
  def parsed_body
    ::MultiJson.decode(request.body)
  end
end

post '/hook' do
  puts parsed_body
end