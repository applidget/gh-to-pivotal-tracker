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
    milestone_payload = issue["milestone"].present? ? issue["milestone"] : nil

    PayloadLoader.manage(id, number, title, html_url, labels, author, state, body, milestone_payload)
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
    milestone_payload = web_hook.issue["milestone"].present? ? web_hook.issue["milestone"] : nil

    PayloadLoader.manage(id, number, title, html_url, labels, author, state, body, milestone_payload)
  end

  def self.manage id, number, title, html_url, labels, author, state, body, milestone_payload
      milestone_id = milestone_payload ? milestone_payload['id'] : nil
      epic = Milestone.where(id: milestone_id).first
      if milestone_id.present?
        if epic.nil?
          epic = Milestone.create_milestone(milestone_payload)
        end
      end

      ticket = Ticket.insert_or_update id, number, title, html_url, labels, author, state, body, milestone_id
      ticket.create_story
      ticket.set_epic epic if epic.present?
      ticket.sync
    end
end
