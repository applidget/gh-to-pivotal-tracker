class Milestone
  include Mongoid::Document
  include Mongoid::Timestamps

  #Github milestone
  field :id
  field :title
  field :description
  field :open_issues
  field :closed_issues
  field :state
  field :due_on
  field :closed_at
  field :html_url

  field :pt_epic_id

  def self.create_milestone payload_milestone
    id = payload_milestone["id"]
    title = payload_milestone["title"]
    description = payload_milestone["description"]
    open_issues = payload_milestone["open_issues"]
    closed_issues = payload_milestone["closed_issues"]
    state = payload_milestone["state"]
    due_on = payload_milestone['due_on']
    closed_at = payload_milestone["closed_at"]
    html_url = payload_milestone["html_url"]

    milestone = Milestone.insert_or_update(id, title, description, open_issues, closed_at, state, due_on, closed_at, html_url)
    milestone.create_epic
    milestone
  end

  def self.insert_or_update(id, title, description, open_issues, closed_issues, state, due_on, closed_at, html_url)
    milestone = Milestone.where(id: id).first
    params = {
        title: title,
        description: description,
        open_issues: open_issues,
        closed_issues: closed_issues,
        state: state,
        due_on: due_on,
        closed_at: closed_at,
        html_url: html_url
      }
    if milestone.nil?
      milestone = Milestone.create({id: id}.merge!(params))
    else
      milestone.update_attributes(params)
    end
    milestone
  end

  def create_epic
    return unless pt_epic_id.blank?
    @pivotal_epic = Ticket.pivotal_project.create_epic(name: title, description: html_url)
    if @pivotal_epic.id
      self.pt_epic_id = @pivotal_epic.id
      self.save
    end
  end

end
