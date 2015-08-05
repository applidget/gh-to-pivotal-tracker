require "octokit"

class GithubSyncer

  def run(project)
    
    current_page = Octokit.issues APP_CONFIG["github_repo_name"], :access_token => APP_CONFIG["github_access_token"]
    loop do
      current_page.each do |issue|
        puts issue["title"]
      end
      debugger
      current_page = Octokit.last_response.rels[:next].get.data
      break if current_page == nil
    end
    nil
  end
end