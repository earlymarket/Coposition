require "rails_helper"

describe ::Users::Friends::FriendsShowDevicePresenter do
  subject(:show_device_presenter) { described_class.new(user, id: friend.id, device_id: device.id) }
  let(:user) do
    us = FactoryBot.create(:user)
    Approval.add_friend(us, friend)
    Approval.add_friend(friend, us)
    us
  end
  let(:friend) { create(:user) }
  let(:device) do
    device = create(:device, user_id: friend.id)
    device.permitted_users << user
    device
  end
  let(:checkins) do
    create(:checkin, device_id: device.id)
    create(:checkin, device_id: device.id).reverse_geocode!
    create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(friend device gon checkins form_for form_path form_range_filter).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "friend" do
    it "returns friend" do
      expect(show_device_presenter.friend).to eq friend
    end
  end

  describe "device" do
    it "returns a device" do
      expect(show_device_presenter.device).to be_kind_of Device
    end
  end

  describe "gon" do
    it "returns a hash" do
      expect(show_device_presenter.gon).to be_kind_of Hash
    end

    it "calls device_checkins" do
      allow(show_device_presenter).to receive(:device_checkins).and_return device.checkins
      show_device_presenter.gon
      expect(show_device_presenter).to have_received(:device_checkins).at_least(1).times
    end
  end

  describe "checkins" do
    it "returns a hash" do
      expect(show_device_presenter.checkins).to be_kind_of Hash
    end

    it "calls device_checkins" do
      allow(show_device_presenter).to receive(:device_checkins).and_return [checkins]
      show_device_presenter.checkins
      expect(show_device_presenter).to have_received(:device_checkins)
    end
  end

  describe "form_for" do
    it "returns a User" do
      expect(show_device_presenter.form_for).to be_kind_of User
    end
  end

  describe "form_path" do
    it "returns friends show device path" do
      expect(show_device_presenter.form_path).to eq(
        "/users/#{user.url_id}/friends/#{friend.url_id}/show_device?device_id=#{device.id}"
      )
    end
  end

  describe "form_range_filter" do
    let(:date) { 1.week.ago }
    let(:output) { show_device_presenter.form_range_filter("range", date) }

    it "returns a link containing the provided text to get checkins for a certain range" do
      expect(output).to match "range"
    end

    it "returns a link containing the provided range" do
      expect(output).to match date.to_date.to_s
    end
  end

  describe "device_checkins" do
    it "retuns an array" do
      expect(show_device_presenter.send(:device_checkins)).to be_kind_of ActiveRecord::AssociationRelation
    end

    it "returns device.safe_checkin_info_for" do
      checkins = device.safe_checkin_info_for(permissible: user, action: "index", multiple_devices: true)
      expect(show_device_presenter.send(:device_checkins)).to eq checkins
    end
  end
end
