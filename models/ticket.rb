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

  TOKEN = "--- "

  #Github issue params
  field :gh_id
  field :gh_number
  field :gh_title
  field :gh_html_url
  field :gh_labels, type: Array, default: []
  field :gh_author
  field :gh_state
  field :gh_body
  field :gh_need_comment, type: Boolean, default: false

  #Pivotal Tracker parmas
  field :pt_id
  field :pt_current_eta
  field :pt_previous_eta
  
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
    return nil if pt_id.nil?
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
    return if pt_id == nil
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
    message = "\n\n#{TOKEN}\n"
    message += "**Pivotal Tracker** - [##{story.id}](#{story.url})\n"
    message += "*Estimation*: **#{story.estimate} points**\n" if !story.estimate.blank?
    message += eta_string
    message += "\n\n#{TOKEN}\n"
  end

  def github_comment icon = ":checkered_flag:"
    message = "#{icon} *New* #{eta_string true}\nView in [Pivotal Tracker](#{pivotal_story.url})" 
  end

  def eta_string(display_previous = false)
    message = "*ETA*: **#{pt_current_eta.strftime("#{pt_current_eta.day.ordinalize} %B %Y")}**" if !pt_current_eta.blank?
    message += " (was #{pt_previous_eta.strftime("#{pt_previous_eta.day.ordinalize} %B %Y")})\n" if display_previous && !pt_previous_eta.blank? && pt_previous_eta != pt_current_eta
    message ||= ""
  end

  def update_github_description
    unless self.gh_body.gsub!(/^#{TOKEN}(.|\n)*#{TOKEN}/m, github_message)
      self.gh_body += github_message
    end
    Ticket.github_client.update_issue APP_CONFIG["github_repo_name"], gh_number, gh_title, self.gh_body
  end

  def self.github_client
    @@github_client ||= Octokit::Client.new(:access_token => APP_CONFIG["github_access_token"])
  end

  def manage_comment
    if gh_need_comment
      create_comment
      self.set(:gh_need_comment => false)
    end
  end

  def create_comment
    Ticket.github_client.add_comment APP_CONFIG["github_repo_name"], gh_number, github_comment
  end

  def self.compute_eta
    project = pivotal_project
    project.iterations(scope:"current_backlog").each do |iter|
      iter.stories.each do |story|
        ticket = Ticket.where(pt_id: story.id).first
        unless ticket.nil?
          if ticket.pt_current_eta.blank?
            ticket.update_attributes({pt_current_eta: iter.finish - 2, gh_need_comment: true})
          elsif ticket.pt_current_eta != iter.finish - 2
            current_eta = ticket.pt_current_eta
            ticket.update_attributes({pt_current_eta: iter.finish - 2, pt_previous_eta: current_eta, gh_need_comment: true})
          end
        end
      end
    end
  end

end
