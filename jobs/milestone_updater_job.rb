class MilestoneUpdaterJob
  @queue = :gh_update
  def self.perform
    consumer = MilestoneUpdater.new
    consumer.sync
  end
end