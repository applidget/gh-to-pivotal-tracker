#As specified here https://github.com/applidget/products/blob/master/docs/drafts/gh-to-pivotal-sync.md#données-sauvegardées

class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps
  
  #Github issue params
  field :gh_id
  field :gh_number
  field :gh_title
  field :gh_html_url
  field :gh_labels, type: Array
  field :gh_author
  field :gh_state
  
  #Pivotal Tracker parmas
  field :pt_id
end