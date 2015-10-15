require 'octokit'

class MilestoneUpdater

  def sync
    client = Octokit::Client.new(:access_token => APP_CONFIG["github_access_token"])
    client.auto_paginate = true
    issues = client.issues APP_CONFIG["github_repo_name"], :per_page => 100

    issues.each do |issue|
      PayloadLoader.consume(issue)
    end

  end

  


end
