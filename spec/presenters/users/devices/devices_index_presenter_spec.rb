require "rails_helper"

describe ::Users::Devices::DevicesIndexPresenter do
  subject(:index_presenter) { described_class.new(user, id: device.id) }
  let(:user) { create(:user) }
  let(:device) { create(:device, user_id: user.id) }
  let(:checkins) do
    create(:checkin, device_id: device.id)
    create(:checkin, device_id: device.id).reverse_geocode!
    create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(user devices index_devices index_gon).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "user" do
    it "returns user" do
      expect(index_presenter.user).to eq user
    end
  end

  describe "devices" do
    it "returns paginated devices" do
      expect(index_presenter.devices).to be_kind_of WillPaginate::Collection
    end
  end

  describe "index_devices" do
    it "returns devices" do
      expect(index_presenter.index_devices).to eq(user.devices)
    end

    it "returns a pginated collection of devices" do
      expect(index_presenter.index_devices).to be_kind_of WillPaginate::Collection
    end

    it "calls Device.geocode_last_checkins" do
      allow(Device).to receive(:geocode_last_checkins)
      index_presenter.index_devices
      expect(Device).to have_received(:geocode_last_checkins).at_least(1).times
    end
  end

  describe "index_gon" do
    it "returns a hash" do
      expect(index_presenter.index_gon).to be_kind_of Hash
    end

    it "calls gon_index_checkins" do
      allow(index_presenter).to receive(:gon_index_checkins)
      index_presenter.index_gon
      expect(index_presenter).to have_received(:gon_index_checkins)
    end

    it "calls not_coposition_developers" do
      allow(Permission).to receive(:not_coposition_developers)
      index_presenter.index_gon
      expect(Permission).to have_received(:not_coposition_developers)
    end
  end

  describe "gon_index_checkins" do
    before do
      checkins
    end

    it "returns an array" do
      expect(index_presenter.send(:gon_index_checkins)).to be_kind_of Array
    end

    it "returns checkins sorted by created at" do
      expect(index_presenter.send(:gon_index_checkins)[0]["id"]).to eq Checkin.first.id
    end

    it "returns one checkin for each device" do
      create(:device, user: user)
      create(:checkin, device: Device.last)
      checkins = index_presenter.send(:gon_index_checkins)
      devices_count = Device.joins(:checkins).distinct.all.count
      expect(checkins.length).to eq devices_count
    end
  end
end
