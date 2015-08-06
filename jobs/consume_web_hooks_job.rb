class ConsumeWebHooksJob
  @queue = :main
  def self.perform
    consumer = WebHookConsumer.new
    consumer.sync
  end
end