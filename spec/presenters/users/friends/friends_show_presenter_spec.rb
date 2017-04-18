require "rails_helper"

describe ::Users::Friends::FriendsShowPresenter do
  subject(:show_presenter) { described_class.new(user, id: friend.id) }
  let(:user) do
    us = FactoryGirl.create(:user)
    Approval.add_friend(us, friend)
    Approval.add_friend(friend, us)
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
    %i(friend devices gon friend_name).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "friend" do
    it "returns friend" do
      expect(show_presenter.friend).to eq friend
    end
  end

  describe "devices" do
    it "returns paginated devices" do
      expect(show_presenter.devices).to be_kind_of WillPaginate::Collection
    end

    it "only finds uncloaked devices" do
      expect(show_presenter.devices.all? { |device| !device.cloaked }).to eq true
    end

    it "calls Device.ordered_by_checkins" do
      allow(Device).to receive(:ordered_by_checkins).and_return(friend.devices)
      show_presenter
      expect(Device).to have_received(:ordered_by_checkins)
    end
  end

  describe "gon" do
    it "returns a hash" do
      expect(show_presenter.gon).to be_kind_of Hash
    end

    it "calls most_recent_checkins" do
      allow(show_presenter).to receive(:most_recent_checkins)
      show_presenter.gon
      expect(show_presenter).to have_received(:most_recent_checkins)
    end
  end

  describe "friend_name" do
    it "returns friends username if present" do
      expect(show_presenter.friend_name).to eq friend.username
    end

    it "returns start of friends email if no username" do
      friend.update(username: "")
      expect(show_presenter.friend_name).to eq friend.email.split("@").first
    end
  end

  describe "most_recent_checkins" do
    it "retuns an array" do
      checkins
      expect(show_presenter.send(:most_recent_checkins)).to be_kind_of Array
    end
  end
end