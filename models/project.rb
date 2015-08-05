#This model is used to store global sync state

class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :last_pt_synced_at, type: DateTime
  field :list_github_synced_at, type: DateTime
end