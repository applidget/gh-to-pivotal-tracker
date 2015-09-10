require "spec_helper"

describe WebHook do
  before(:each) do
    @event = WebHook.new
  end

  describe "#something" do
    it "runs some test" do
      expect(3+1).to eq 4
    end
  end
end
