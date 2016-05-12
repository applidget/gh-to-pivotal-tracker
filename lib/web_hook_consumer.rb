require 'byebug'
class WebHookConsumer
  
  def sync
    loop do
      web_hook = WebHook.where(sync_state: "TODO").find_one_and_update({"$set" => {sync_state: "PROCESSING"}, "$currentDate" => {sync_ts: true}})
      break if web_hook.nil?
      begin
        PayloadLoader.consume(web_hook.issue)
        web_hook.set(sync_state: "DONE", sync_ts: DateTime.now)
      rescue Exception => e
        web_hook.set(sync_state: "TODO")
        puts "Issue number: '#{web_hook.issue["number"]}', title : '#{web_hook.issue["title"]}' could not be updated in PT"
         break
      end
    end
  end

end