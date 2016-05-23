require 'rails_helper'

RSpec.describe Request, type: :model do

  let(:developer) { FactoryGirl::create(:developer) }
  let(:request) do
    req = FactoryGirl::create :request
    req.developer = developer
    req
  end

  describe "relationships" do

    it "should have a developer" do
      expect(request.developer).to eq developer
    end
  end

  describe "slack" do
    it "should generate a helpful message for slack" do
      expect(request.slack_message).to eq "A developer has made a new request, id: #{request.developer_id}, company name: #{Developer.find(request.developer_id).company_name}, controller: #{request.controller}, action: #{request.action}, user_id: #{request.user_id}."
    end
  end
end
