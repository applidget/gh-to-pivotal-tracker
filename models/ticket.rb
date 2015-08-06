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
  validates_uniqueness_of :gh_id, :gh_number, :pt_id
  
  def should_create_story?
    pt_id.blank? && gh_labels.include?(TRIGGERING_LABEL)
  end
  
  def create_story
    return unless should_create_story?
    @pivotal_story = Ticket.pivotal_project.create_story(name: gh_title, description: gh_html_url, story_type: "chore")
    if @pivotal_story.id
      self.pt_id = @pivotal_story.id
      self.save
      sync
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
  
  STATE_MAPPING = {
    "closed" =>
  }
  
  def sync
    return nil if should_create_story?
    sync_labels
    sync_state
    
  end
  
  def sync_state
    return if should_create_story?
    story = pivotal_story
    story.state = self.gh_state
  end
  
  def sync_labels
    return if should_create_story?
    story = pivotal_story
    story.labels = self.gh_labels.map { |label| TrackerApi::Resources::Label.new(name: label)}
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
end
