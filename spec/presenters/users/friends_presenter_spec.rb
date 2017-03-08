require "rails_helper"

describe ::Users::FriendsPresenter do
  subject(:friends) { described_class.new(user, { id: friend.id, device_id: device.id }, "show") }
  let(:user) do
    us = FactoryGirl.create(:user)
    us.friends << friend
    friend.friends << us
    us
  end
  let(:friend) { FactoryGirl.create(:user) }
  let(:device) do
    device = FactoryGirl.create(:device, user_id: friend.id)
    device.permitted_users << user
    device
  end
  let(:checkins) do
    FactoryGirl.create(:checkin, device_id: device.id)
    FactoryGirl.create(:checkin, device_id: device.id).reverse_geocode!
    FactoryGirl.create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(show show_device index_gon show_device_gon show_checkins).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "show" do
    it "returns WillPaginate::collection" do
      expect(friends.show).to be_kind_of WillPaginate::Collection
    end

    it "only finds uncloaked devices" do
      expect(friends.show.all? { |device| !device.cloaked }).to eq true
    end

    it "calls Device.ordered_by_checkins" do
      allow(Device).to receive(:ordered_by_checkins).and_return(friend.devices)
      friends.show
      expect(Device).to have_received(:ordered_by_checkins).twice
    end
  end

  describe "show_device" do
    it "returns a device" do
      expect(friends.show_device).to be_kind_of Device
    end
  end

  describe "index_gon" do
    it "returns a hash" do
      expect(friends.index_gon).to be_kind_of Hash
    end

    it "calls most_recent_checkins" do
      allow(friends).to receive(:most_recent_checkins)
      friends.index_gon
      expect(friends).to have_received(:most_recent_checkins)
    end
  end

  describe "show_device_gon" do
    it "returns a hash" do
      expect(friends.show_device_gon).to be_kind_of Hash
    end

    it "calls device_checkins" do
      allow(friends).to receive(:device_checkins).and_return [checkins]
      friends.show_device_gon
      expect(friends).to have_received(:device_checkins)
    end
  end

  describe "show_checkins" do
    it "returns a hash" do
      expect(friends.show_checkins).to be_kind_of Hash
    end

    it "calls device_checkins" do
      allow(friends).to receive(:device_checkins).and_return [checkins]
      friends.show_checkins
      expect(friends).to have_received(:device_checkins)
    end
  end

  describe "most_recent_checkins" do
    it "retuns an array" do
      expect(friends.send(:most_recent_checkins)).to be_kind_of Array
    end

    it "calls device.safe_checkin_info_for" do
      # can't find a way to get this to work, despite this method definitely being called
      allow(device).to receive(:safe_checkin_info_for).and_return device.checkins
      friends.send(:most_recent_checkins)
      expect(device).to have_received(:safe_checkin_info_for)
    end
  end

  describe "device_checkins" do
    it "retuns an array" do
      expect(friends.send(:most_recent_checkins)).to be_kind_of Array
    end

    it "returns device.safe_checkin_info_for" do
      checkins = device.safe_checkin_info_for(permissible: user, action: "index", multiple_devices: true)
      expect(friends.send(:device_checkins)).to eq checkins
    end
  end
end
