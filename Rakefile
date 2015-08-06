%w{ rubygems bundler find }.each { |lib| require lib }

require "resque/tasks"
require 'resque/scheduler/tasks'

require "./environment"

task :default => :spec