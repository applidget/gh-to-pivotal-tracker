env = ENV["RACK_ENV"] || "development"
APP_CONFIG = YAML.load(ERB.new(File.read(File.join(File.dirname(__FILE__), '../config.yml'))).result)[env]
