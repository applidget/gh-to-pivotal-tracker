require "spec_helper"

describe WebHook do
  before(:each) do
    @web_hook = FactoryGirl.build :web_hook
  end

  describe "creation" do
    it "creates a basic webhook with some fake data" do
      expect(@web_hook).to be_valid
    end
  end
end
