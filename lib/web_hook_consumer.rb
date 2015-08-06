class WebHookConsumer
  
  def sync
    loop do
      web_hook = WebHook.where(sync_state: "TODO").find_one_and_update({"$set" => {sync_state: "PROCESSING"}, "$currentDate": {sync_ts: true}})
      break if web_hook.nil?
      consume web_hook
      web_hook.set(sync_state: "DONE", sync_ts: DateTime.now)
    end
  end 

  def consume web_hook
    id = web_hook.issue["id"]
    number = web_hook.issue["number"]
    title = web_hook.issue["title"]
    html_url = web_hook.issue["html_url"]
    labels = web_hook.issue["labels"]
    author = web_hook.sender["login"]
    state = web_hook.issue["state"]
    ticket = Ticket.insert_or_update id, number, title, html_url, labels, author, state
    ticket.sync
  end
end