class MilestoneUpdaterJob
  @queue = :milestone
  def self.perform
    consumer = MilestoneUpdater.new
    consumer.sync
  end
end