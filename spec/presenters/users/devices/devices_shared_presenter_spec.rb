require "rails_helper"

describe ::Users::Devices::DevicesSharedPresenter do
  subject(:shared_presenter) { described_class.new(user, id: device.id) }
  let(:user) { create(:user) }
  let(:device) { create(:device, user_id: user.id) }
  let(:checkins) do
    create(:checkin, device_id: device.id)
    create(:checkin, device_id: device.id).reverse_geocode!
    create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(user device shared_gon).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "user" do
    it "returns user" do
      expect(shared_presenter.user).to eq user
    end
  end

  describe "device" do
    it "returns a device" do
      expect(shared_presenter.device).to be_kind_of Device
    end
  end

  describe "shared_gon" do
    it "returns a hash" do
      expect(shared_presenter.shared_gon).to be_kind_of Hash
    end

    it "calls gon_shared_checkin" do
      allow(shared_presenter).to receive(:gon_shared_checkin)
      shared_presenter.shared_gon
      expect(shared_presenter).to have_received(:gon_shared_checkin)
    end
  end

  describe "gon_shared_checkin" do
    it "returns nothing if no checkin present" do
      expect(shared_presenter.send(:gon_shared_checkin)).to eq nil
    end

    context "with checkins" do
      before do
        checkins
      end

      it "returns a checkin" do
        expect(shared_presenter.send(:gon_shared_checkin)).to be_kind_of Checkin
      end

      it "returns a checkin with fogged attributes if fogged" do
        expect(shared_presenter.send(:gon_shared_checkin)["lat"]).to eq Checkin.first.fogged_lat
      end

      it "returns an unfogged checkin if device and checkin unfogged" do
        device.update(fogged: false)
        Checkin.first.update(fogged: false)
        expect(shared_presenter.send(:gon_shared_checkin)["lat"]).to eq Checkin.first.lat
      end
    end
  end
end
