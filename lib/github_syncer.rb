require "octokit"

class GithubSyncer
  
  
  def run(project)
    client = Octokit::Client.new(:access_token => APP_CONFIG["github_access_token"])
    repo = client.
  end
end