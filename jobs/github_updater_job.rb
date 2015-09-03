class GithubUpdaterJob
  @queue = :gh_update
  def self.perform
    consumer = GithubUpdater.new
    consumer.sync
  end
end