env = ENV["RACK_ENV"] || "development"

Resque.redis = YAML.load(ERB.new(File.read(File.join(File.dirname(__FILE__), '../resque.yml'))).result)[env]
Resque.logger = Logger.new(STDOUT)
Resque.logger.level = Logger::INFO
