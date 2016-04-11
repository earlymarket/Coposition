require 'rails_helper'

RSpec.describe FriendsHelper, :type => :helper do
  let(:friend) { FactoryGirl::create :user }
  let(:device) do
    device = FactoryGirl::create(:device, user_id: friend.id)
    device.checkins << [FactoryGirl::create(:checkin), FactoryGirl::create(:checkin)]
    device
  end

  describe '#friends_name' do
    it "should return the start of the users email if no username" do
      friend.update(username: '')
      expect(friend.email).to include helper.friends_name(friend)
    end

    it "should return the username user has a username" do
      expect(helper.friends_name(friend)).to match friend.username
    end
  end

  describe '#friends_last_checkin' do
    it "returns no location if user can not see any of friends checkins" do
      expect(helper.friends_last_checkin([])).to match('No location')
    end

    it "returns the last checkin address if it exists" do
      expect(helper.friends_last_checkin(device.checkins)).to match('Last available')
      expect(helper.friends_last_checkin(device.checkins)).to match(device.checkins.first.fogged_area.to_s)
    end
  end
end

