require "spec_helper"

describe WebHook do
  before(:each) do
    issue = {
      "id" => "12jgfghjk6543",
      "number" => 7654,
      "title" => "Some regex issue",
      "html_url" => "http://github.com",
      "labels" => [{:name => "bug"}, {name:"qualified"}],
      "author" => "rpechayr",
      "state" => "open",
      "body" => "Some really short body"
    }
    @web_hook = WebHook.new issue: issue , action: {key: "value"}, sender: {key: "value"}
  end

  describe "#something" do
    it "runs some test" do
      expect(@web_hook).to be_valid
    end
  end
end
