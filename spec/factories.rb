FactoryGirl.define do
  factory :web_hook do
    sequence(:issue, 1) do |n|
      {
        "id" => "#{n}",
        "number" => n,
        "title" => "Some regex issue #{n}",
        "html_url" => "http://github.com/#{n}",
        "labels" => [{:name => "bug"}, {name:"qualified"}],
        "author" => "rpechayr",
        "state" => "open",
        "body" => "Some really short body #{n}"
      }
    end
    action({key: "value"})
    sender({key: "value"})
  end
end