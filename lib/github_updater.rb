class GithubUpdater

  def sync
    Ticket.where(gh_state: "open").each do |ticket|
      if %w(unscheduled unstarted started).include?(ticket.pivotal_story.current_state)
        ticket.update_github_description
      end
    end
  end

end