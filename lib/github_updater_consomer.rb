class GithubUpdaterConsomer

  def sync
    Ticket.each do |ticket|
      case
      when %w(unscheduled unstarted started).include?(ticket.pivotal_story.current_state)
        ticket.update_github_description
      end
    end
  end

end