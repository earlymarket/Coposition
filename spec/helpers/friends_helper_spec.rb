require 'rails_helper'

RSpec.describe FriendsHelper, :type => :helper do
  let(:friend) { FactoryGirl::create :user }

  describe '#friends_name' do
    it "should return the start of the users email if no username" do
      friend.update(username: '')
      expect(friend.email).to include helper.friends_name(friend)
    end

    it "should return the username user has a username" do
      expect(helper.friends_name(friend)).to match friend.username
    end
  end
end
