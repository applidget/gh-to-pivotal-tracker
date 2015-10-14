require 'octokit'

class MilestoneUpdater

  def sync
    client = Octokit::Client.new(:access_token => APP_CONFIG["github_access_token"])
    client.auto_paginate = true
    issues = client.issues APP_CONFIG["github_repo_name"], :per_page => 100

    issues.each do |issue|
      consume issue
    end

  end

  def consume issue
    id = issue["id"]
    number = issue["number"]
    title = issue["title"]
    html_url = issue["html_url"]
    labels = issue["labels"].map {|label| label["name"]}
    author = issue["user"]["login"]
    state = issue["state"]
    body = issue["body"]
    milestone_id = issue["milestone"].present? ? issue["milestone"]["id"] : nil

    WebHookConsumer.manage(id, number, title, html_url, labels, author, state, body, milestone_id)
  end


end
