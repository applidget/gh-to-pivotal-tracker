%w{ rubygems bundler find }.each { |lib| require lib }
Dir.glob('lib/tasks/*.rake').each { |r| load r}

require "./environment"

namespace :resque do
  task :setup do
    require "resque/tasks"
    require 'resque/scheduler/tasks'
    Resque.schedule = YAML.load_file(Rails.root.join('config', 'schedule.yml'))
  end
end
