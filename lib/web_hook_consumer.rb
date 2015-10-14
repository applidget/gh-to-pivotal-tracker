class WebHookConsumer
  
  def sync
    loop do
      web_hook = WebHook.where(sync_state: "TODO").find_one_and_update({"$set" => {sync_state: "PROCESSING"}, "$currentDate" => {sync_ts: true}})
      break if web_hook.nil?
      PayloadLoader.consume_web_hook(web_hook)
      web_hook.set(sync_state: "DONE", sync_ts: DateTime.now)
    end
  end

end