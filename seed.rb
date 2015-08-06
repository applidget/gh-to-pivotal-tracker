require "./environment"

10.times do |cpt|
  WebHook.create!(
    action: "open",
    issue: {
      state: "open",
      id: cpt,
      number: cpt,
      title: "Issue ##{cpt}",
      html_url: "http://issue.com/#{cpt}",
      labels: ["synced", "label1", "label-seed"],
      author: "smartgeek"
    },
    sender: {
      login: "smartgeek"
    }
  )
end