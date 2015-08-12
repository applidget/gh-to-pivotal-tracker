class GithubUpdater
  
  def sync
    Ticket.compute_eta
    Ticket.where(gh_state: "open").each do |ticket|
      next if ticket.pivotal_story.nil?
      if %w(unscheduled unstarted started).include?(ticket.pivotal_story.current_state)
        ticket.update_github_description
      end
    end
  end

end