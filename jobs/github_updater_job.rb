class GithubUpdaterJob
  @queue = :main
  def self.perform
    consumer = GithubUpdater.new
    consumer.sync
  end
end