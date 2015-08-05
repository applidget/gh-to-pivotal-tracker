class WebHookConsumer

  def sync
    WebHook.each | web_hook | 
      consume web_hook
    end
  end 

	def consume web_hook
		id = web_hook.issue["id"]
		number = web_hook.issue["number"]
		title = web_hook.issue["title"]
		html_url = web_hook.issue["html_url"]
		labels = web_hook.issue["labels"]
		author = web_hook.sender["login"]
		state = web_hook.state

    ticket = Ticket.find_or_create_by gh_id: id
    ticket.update_attributes {
      gh_id: id,
      gh_number: number,
      gh_title: title,
      gh_html_url: html_url,
      gh_labels: labels,
      gh_author: author,
      gh_state: state  
    }
	end
end