require "octokit"

class GithubSyncer

  def run(project)
    Octokit.auto_paginate = true
    current_page = Octokit.issues APP_CONFIG["github_repo_name"], :access_token => APP_CONFIG["github_access_token"]
    current_page.each do |issue|
      
      gh_id = issue["id"]
      gh_number = issue["number"]
      gh_title = issue["title"]
      gh_html_url = issue["html_url"]
      gh_labels = issue["labels"].map{|label| label["name"]}
      gh_author = "rpechayr" #TODO: change this
      gh_state = issue["state"]
      
    end
    
  end
end