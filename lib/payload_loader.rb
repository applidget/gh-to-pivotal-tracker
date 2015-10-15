class PayloadLoader

  def self.consume issue
    id = issue["id"]
    number = issue["number"]
    title = issue["title"]
    html_url = issue["html_url"]
    labels = issue["labels"].map {|label| label["name"]}
    author = issue["user"]["login"]
    state = issue["state"]
    body = issue["body"]
    milestone_payload = issue["milestone"].present? ? issue["milestone"] : nil

    PayloadLoader.manage(issue, milestone_payload)
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
