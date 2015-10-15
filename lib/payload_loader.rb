class PayloadLoader

  def self.consume issue_payload
    milestone_payload = issue_payload["milestone"].present? ? issue_payload["milestone"] : nil

    PayloadLoader.manage(issue_payload, milestone_payload)
  end

  def self.manage issue_payload, milestone_payload
      milestone_id = milestone_payload ? milestone_payload['id'] : nil
      epic = Milestone.where(id: milestone_id).first
      if milestone_id.present?
        if epic.nil?
          epic = Milestone.create_milestone(milestone_payload)
        end
      end

      ticket = Ticket.insert_or_update(issue_payload)
      ticket.create_story
      ticket.set_epic epic if epic.present?
      ticket.sync
    end
end
