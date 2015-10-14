class PayloadLoader

  def self.consume_issue issue
    id = issue["id"]
    number = issue["number"]
    title = issue["title"]
    html_url = issue["html_url"]
    labels = issue["labels"].map {|label| label["name"]}
    author = issue["user"]["login"]
    state = issue["state"]
    body = issue["body"]
    milestone_id = issue["milestone"].present? ? issue["milestone"]["id"] : nil

    WebHookConsumer.manage(id, number, title, html_url, labels, author, state, body, milestone_id)
  end

  def self.consume_web_hook web_hook
    id = web_hook.issue["id"]
    number = web_hook.issue["number"]
    title = web_hook.issue["title"]
    html_url = web_hook.issue["html_url"]
    labels = web_hook.issue["labels"].map {|label| label["name"]}
    author = web_hook.sender["login"]
    state = web_hook.issue["state"]
    body = web_hook.issue["body"]
    milestone_id = web_hook.issue["milestone"].present? ? web_hook.issue["milestone"]["id"] : nil

    self.manage(id, number, title, html_url, labels, author, state, body, milestone_id)
  end

  private 
    def manage id, number, title, html_url, labels, author, state, body, milestone_id
      epic = Milestone.where(id: milestone_id).first
      if milestone_id.present?
        if epic.nil?
          epic = Milestone.create_milestone(web_hook.issue["milestone"])
        end
      end

      ticket = Ticket.insert_or_update id, number, title, html_url, labels, author, state, body, milestone_id
      ticket.create_story
      ticket.set_epic epic
      ticket.sync
    end
end
