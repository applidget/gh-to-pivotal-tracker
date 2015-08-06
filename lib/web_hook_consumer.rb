class WebHookConsumer

  def sync
    WebHook.each { | web_hook |
      consume web_hook
    }
  end 

  def consume web_hook
    id = web_hook.issue["id"]
    number = web_hook.issue["number"]
    title = web_hook.issue["title"]
    html_url = web_hook.issue["html_url"]
    labels = web_hook.issue["labels"]
    author = web_hook.sender["login"]
    state = web_hook.action

    Ticket.insert_or_update id, number, title, html_url, labels, author, state
  end
end