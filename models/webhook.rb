class WebHook
	include Mongoid::Document
	include Mongoid::Timestamps

  field :action
  field :issue, type: Hash
  field :sender, type: Hash
	field :sync_state, default: "TODO"
	field :sync_ts, type: DateTime
  
  validates_presence_of :action, :issue, :sender
end