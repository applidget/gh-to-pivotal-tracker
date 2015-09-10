ENV['RACK_ENV'] = 'test'


require "./environment"

require 'rack/test'

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
