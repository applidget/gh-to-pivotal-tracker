class ConsumeGithubUpdaterJob
  @queue = :main
  def self.perform
    consumer = GithubUpdaterConsomer.new
    consumer.sync
  end
end