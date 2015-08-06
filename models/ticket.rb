#As specified here https://github.com/applidget/products/blob/master/docs/drafts/gh-to-pivotal-sync.md#données-sauvegardées

TRIGGERING_LABEL = "synced"

class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #Github issue params
  field :gh_id
  field :gh_number
  field :gh_title
  field :gh_html_url
  field :gh_labels, type: Array, default: []
  field :gh_author
  field :gh_state

  #Pivotal Tracker parmas
  field :pt_id
  
  validates_presence_of :gh_id, :gh_number, :gh_number, :gh_title, :gh_author
  validates_uniqueness_of :gh_id, :gh_number
  validates_uniqueness_of :pt_id, allow_nil: true
  
  def should_create_story?
    pt_id.blank? && gh_labels.include?(TRIGGERING_LABEL)
  end
  
  def create_story
    return unless should_create_story?
    @pivotal_story = Ticket.pivotal_project.create_story(name: gh_title, description: gh_html_url, story_type: "chore")
    if @pivotal_story.id
      self.pt_id = @pivotal_story.id
      self.save
      sync_labels
    end
  end
  
  def pivotal_story
    return nil if should_create_story?
    @pivotal_story ||= Tiket.story_from_id(self.pt_id)
  end

  def status
    return "unscheduled" if pivotal_story.exists?
    pivotal_story.status
  end
  
  def scheduled?
    status != "unscheduled"
  end
  
  def sync_labels
    return nil if should_create_story?
    story = pivotal_story
    story.labels = self.gh_labels.map { |label| TrackerApi::Resources::Label.new(name: label)}
    story.save
  end
  
  def self.pivotal_project
    @@client ||= TrackerApi::Client.new(token: APP_CONFIG["pivotal_tracker_auth_token"].to_s)
    @@project  ||= @@client.project(APP_CONFIG["pivotal_tracker_project_id"])  
  end
  
  def self.list_stories
    pivotal_project.stories
  end
  
  def self.story_from_id(story_id)
    pivotal_project.story(story_id)
  end

  def self.insert_or_update (gh_id, number, title, html_url, labels, author, state)
    ticket = Ticket.where(gh_id: gh_id).first
    params = {
        gh_number: number,
        gh_title: title,
        gh_html_url: html_url,
        gh_labels: labels,
        gh_author: author,
        gh_state: state
      }
    if ticket.nil?
      ticket = Ticket.create({gh_id: gh_id}.merge!(params))
    else
      ticket.update_attributes(params)
    end
    ticket
  end
end
