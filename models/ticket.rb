#As specified here https://github.com/applidget/products/blob/master/docs/drafts/gh-to-pivotal-sync.md#données-sauvegardées

TRIGGERING_LABEL = "synced"

class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  
  STATE_MAPPING = {
    "accepted" => "closed",
    "unstarted" => "open",
    "unscheduled" => "open",
    "started" => "open"
  }
  
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
      sync
    end
  end
  
  def pivotal_story
    return nil if should_create_story?
    @pivotal_story ||= Ticket.story_from_id(self.pt_id)
  end

  def status
    return "unscheduled" if pivotal_story.exists?
    pivotal_story.status
  end
  
  def scheduled?
    status != "unscheduled"
  end
  
  def sync
    sync_labels
    sync_state
    pivotal_story.save
  end
  
  def sync_labels
    return if pt_id == nil
    story = pivotal_story
    story.labels = self.gh_labels.map { |label| TrackerApi::Resources::Label.new(name: label)}
  end
  
  def sync_state
    return if pt_id == nil
    current_state = pivotal_story["current_state"]
    if STATE_MAPPING[current_state] != gh_state
      if gh_state == "open" #Reopen
        #FIXME: side effect, because if closed from PT, the next hook from GH will mark it as unstarted
        pivotal_story.current_state = "unstarted"
        pivotal_story.accepted_at = nil
      else
        #Issue has been closed
        pivotal_story.current_state = "accepted"
      end
    end
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
