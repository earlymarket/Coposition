require 'rails_helper'

RSpec.describe FriendsHelper, :type => :helper do
  let(:friend) { FactoryGirl::create :user }
  let(:device) do
    device = FactoryGirl::create(:device, user_id: friend.id)
    device.checkins << [FactoryGirl::create(:checkin), FactoryGirl::create(:checkin)]
    device
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

