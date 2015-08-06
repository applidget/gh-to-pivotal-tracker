require "./environment"
require './gh-to-pivotal-tracker'

require 'resque/server'

# Protect Resque behind basic auth
resque_password = ENV['RESQUE_SERVER_PASSWORD'] || (
  pass = SecureRandom.hex
  puts "Generated \e[32m/resque\e[0m password is \e[32m#{pass}\e[0m"
  pass
)
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == "admin" && password == resque_password
end

run Rack::URLMap.new \
  "/"       => GithubToPivotalTracker.new,
  "/resque" => Resque::Server.new