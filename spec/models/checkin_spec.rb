require 'rails_helper'

RSpec.describe Checkin, type: :model do

	let(:device) { FactoryGirl::create(:device) }
	let(:checkin) do
    check = FactoryGirl::create(:checkin)
    device.checkins << check
    check
  end

  describe "relationships" do

    it "should have a device" do
      expect(checkin.device).to eq device
    end
  end 

end
