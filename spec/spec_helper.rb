ENV['RACK_ENV'] = 'test'


require "./environment"
require 'webmock/rspec'
require 'rack/test'
require 'factory_girl'
require 'factories'

set :environment, :test

RSpec.configure do |config|
  config.order = "random"
  config.include Rack::Test::Methods

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

end

require "./gh-to-pivotal-tracker"
def app
  GithubToPivotalTracker
end
