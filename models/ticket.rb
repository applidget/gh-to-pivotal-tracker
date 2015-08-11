#As specified here https://github.com/applidget/products/blob/master/docs/drafts/gh-to-pivotal-sync.md#données-sauvegardées
require "octokit"

TRIGGERING_LABEL = "tracked"

class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  
  STATE_MAPPING = {
    "accepted" => "closed",
    "unstarted" => "open",
    "unscheduled" => "open",
    "started" => "open"
  }

  TRACKER_MESSAGE_PREFIX = "In Pivotal Tracker:"

  #Github issue params
  field :gh_id
  field :gh_number
  field :gh_title
  field :gh_html_url
  field :gh_labels, type: Array, default: []
  field :gh_author
  field :gh_state
  field :gh_body

  #Pivotal Tracker parmas
  field :pt_id
  field :pt_current_eta
  field :pt_old_eta
  
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
    @@pivotal_client ||= TrackerApi::Client.new(token: APP_CONFIG["pivotal_tracker_auth_token"].to_s)
    @@pivotal_project  ||= @@pivotal_client.project(APP_CONFIG["pivotal_tracker_project_id"])  
  end
  
  def self.list_stories
    pivotal_project.stories
  end
  
  def self.story_from_id(story_id)
    pivotal_project.story(story_id)
  end

  def self.insert_or_update (gh_id, number, title, html_url, labels, author, state, body)
    ticket = Ticket.where(gh_id: gh_id).first
    params = {
        gh_number: number,
        gh_title: title,
        gh_html_url: html_url,
        gh_labels: labels,
        gh_author: author,
        gh_state: state,
        gh_body: body
      }
    if ticket.nil?
      ticket = Ticket.create({gh_id: gh_id}.merge!(params))
    else
      ticket.update_attributes(params)
    end
    ticket
  end

  def github_message
    story = pivotal_story
    message = "#{TRACKER_MESSAGE_PREFIX} [#{story.id}](#{story.url})"
    message += ", Estimation: #{story.estimate} points" if !story.estimate.blank?
    message += ", ETA: #{pt_current_eta.strftime("#{pt_current_eta.day.ordinalize} %B %Y")}" if !pt_current_eta.blank?
    message += ", initial ETA: #{pt_old_eta.strftime("#{pt_old_eta.day.ordinalize} %B %Y")}" if !pt_old_eta.blank?
    message
  end

  def update_github_description
    unless self.gh_body.gsub!(/^#{TRACKER_MESSAGE_PREFIX}.*/, github_message)
      self.gh_body += github_message
    end
    Ticket.github_client.update_issue APP_CONFIG["github_repo_name"], gh_number, gh_title, self.gh_body
  end

  def self.github_client
    @@github_client ||= Octokit::Client.new(:access_token => APP_CONFIG["github_access_token"])
  end

  def self.compute_eta
    project = pivotal_project
    project.iterations(scope:"current_backlog").each do |iter|
      iter.stories.each do |story|
        ticket = Ticket.where(pt_id: story.id).first
        unless ticket.nil?
          if ticket.pt_current_eta.present? && ticket.pt_old_eta.nil? && ticket.pt_current_eta != iter.finish - 2
            ticket.update({pt_old_eta: ticket.pt_current_eta })
          end
          ticket.update({pt_current_eta: iter.finish - 2})
        end
      end
    end
  end

end
