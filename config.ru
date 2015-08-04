# Load app
require './gh-to-pivotal-tracker'

run Rack::URLMap.new "/" => GithubToPivotalTracker.new