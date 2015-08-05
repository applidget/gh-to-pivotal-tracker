require "./environment"

# Load app
require './gh-to-pivotal-tracker'

use Rack::PostBodyContentTypeParser

run Rack::URLMap.new "/" => GithubToPivotalTracker.new
