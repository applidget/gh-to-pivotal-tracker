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

  def self.create_milestone (payload_milestone)
    milestone = Milestone.insert_or_update(payload_milestone)
    milestone.create_epic
    milestone
  end

  def self.insert_or_update(payload_milestone)
    milestone = Milestone.where(id: payload_milestone["id"]).first

    params = Hash.new
    [:id, :title, :description, :open_issues, :closed_issues, :state, :due_on, :closed_at, :html_url].each do |sym|
      params[sym] = payload_milestone[sym]
    end

    if milestone.nil?
      milestone = Milestone.create({id: params["id"]}.merge!(params))
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
