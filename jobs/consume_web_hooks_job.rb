class ConsumeWebHooksJob
  @queue = :main
  
  def self.perform
    puts "Syncing now"
    puts "Got 0 WEbhooks"
  end
end