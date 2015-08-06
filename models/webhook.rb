class WebHook
	include Mongoid::Document
	include Mongoid::Timestamps

  field :action
  field :issue, type: Hash
  field :sender, type: Hash
  
  validates_presence_of :action, :issue, :sender
end