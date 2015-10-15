require  "spec_helper"
describe WebHookConsumer do
  it "should consume webhook" do
    
    issue = {
      "id" => "12jgfghjk6543",
      "number" => 7654,
      "title" => "Some regex issue",
      "html_url" => "http://github.com",
      "labels" => [{:name => "bug"}, {name:"qualified"}],
      "user" => {"login" => "rpechayr"},
      "state" => "open",
      "body" => "Some really short body"
    }
    stub_request(:any, "www.pivotaltracker.com")
    web_hook = WebHook.create issue: issue , action: {key: "value"}, sender: {key: "value"}
    consumer = WebHookConsumer.new
    consumer.sync
  end
end