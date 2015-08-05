require "sinatra/base"
require "sinatra/config_file"
require "sinatra/reloader"
require "multi_json"

class GithubToPivotalTracker < Sinatra::Base
  register Sinatra::ConfigFile

  config_file '#{settings.root}/config/config.yml'

  set :logging, true
  set :dump_errors, true

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def parsed_body
      ::MultiJson.decode(request.body)
    end
  end
  
  post '/hook' do
    debugger
    WebHook.create action: params[:action], issue: params[:issue], sender: params[:sender]
  end
end
