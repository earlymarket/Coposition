require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:user) { FactoryGirl::create :user }
  let(:subscription) { FactoryGirl::create :subscription, user: user }

  describe "relationships" do
    it "should have a user" do
      expect(subscription.user).to eq user
    end
  end
end
