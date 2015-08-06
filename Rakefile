%w{ rubygems bundler find }.each { |lib| require lib }

require "resque/tasks"
require 'resque/scheduler/tasks'

require "./environment"

task :setup do
  require 'resque'
  require 'resque_scheduler'
  require 'resque/scheduler'
end

Resque.schedule = YAML.load_file('./config/schedule.yml')

task :default => :spec