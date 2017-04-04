require "rails_helper"

describe ::Users::DevicesPresenter do
  subject(:devices) { described_class.new(user, { id: device.id }, "index") }
  let(:user) do
    us = FactoryGirl.create(:user)
    us.friends << friend
    us
  end
  let(:friend) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user_id: user.id) }
  let(:checkins) do
    FactoryGirl.create(:checkin, device_id: device.id)
    FactoryGirl.create(:checkin, device_id: device.id).reverse_geocode!
    FactoryGirl.create(:checkin, device_id: device.id)
  end
  let(:devices_show) { described_class.new(user, { id: device.id }, "show") }

  describe "Interface" do
    %i(user devices device checkins filename config index show shared info
       index_gon show_gon shared_gon form_for form_path form_range_filter).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "user" do
    it "returns user" do
      expect(devices.user).to eq user
    end
  end

  describe "devices" do
    it "returns paginated devices" do
      expect(devices.devices).to be_kind_of WillPaginate::Collection
    end
  end

  describe "device" do
    it "returns a device" do
      devices = described_class.new(user, { id: device.id, download: "gpx" }, "show")
      expect(devices.device).to be_kind_of Device
    end
  end

  describe "checkins" do
    it "returns checkins converted to param provided" do
      checkins
      devices = described_class.new(user, { id: device.id, download: "gpx" }, "show")
      expect(devices.checkins).to eq device.checkins.to_gpx
    end
  end

  describe "filename" do
    it "returns a string" do
      devices = described_class.new(user, { id: device.id, download: "gpx" }, "show")
      expect(devices.filename).to be_kind_of String
    end
  end

  describe "config" do
    it "returns a config" do
      device.config = FactoryGirl.create(:config)
      devices = described_class.new(user, { id: device.id }, "info")
      expect(devices.config).to be_kind_of Config
    end
  end

  describe "index" do
    it "returns devices" do
      expect(devices.index).to eq(user.devices)
    end

    it "returns a pginated collection of devices" do
      expect(devices.index).to be_kind_of WillPaginate::Collection
    end

    it "calls Device.geocode_last_checkins" do
      allow(Device).to receive(:geocode_last_checkins)
      devices.index
      expect(Device).to have_received(:geocode_last_checkins).at_least(1).times
    end
  end

  describe "show" do
    it "returns nil if no download params" do
      expect(devices.show).to eq nil
    end

    it "calls checkin conversion method if download params" do
      devices = described_class.new(user, { id: device.id, download: "gpx" }, "show")
      allow(Checkin).to receive(:to_gpx)
      devices.show
      expect(Checkin).to have_received(:to_gpx).at_least(1).times
    end
  end

  describe "shared" do
    it "returns most recent checkin according to delay" do
      checkins
      expect(devices.shared).to eq Checkin.first
    end
  end

  describe "info" do
    it "returns device config" do
      expect(devices.info).to eq device.config
    end
  end

  describe "index_gon" do
    it "returns a hash" do
      expect(devices.index_gon).to be_kind_of Hash
    end

    it "calls gon_index_checkins" do
      allow(devices).to receive(:gon_index_checkins)
      devices.index_gon
      expect(devices).to have_received(:gon_index_checkins)
    end

    it "calls not_coposition_developers" do
      allow(Permission).to receive(:not_coposition_developers)
      devices.index_gon
      expect(Permission).to have_received(:not_coposition_developers)
    end
  end

  describe "show_gon" do
    it "returns a hash" do
      expect(devices_show.show_gon).to be_kind_of Hash
    end

    it "calls gon_show_checkins" do
      allow(devices_show).to receive(:gon_show_checkins).and_return device.checkins
      devices_show.show_gon
      expect(devices_show).to have_received(:gon_show_checkins).twice
    end
  end

  describe "shared_gon" do
    let(:devices) { described_class.new(user, { id: device.id }, "shared") }

    it "returns a hash" do
      expect(devices.shared_gon).to be_kind_of Hash
    end

    it "calls gon_shared_checkin" do
      allow(devices).to receive(:gon_shared_checkin)
      devices.shared_gon
      expect(devices).to have_received(:gon_shared_checkin)
    end
  end

  describe "gon_index_checkins" do
    before do
      checkins
    end

    it "returns an array" do
      expect(devices.send(:gon_index_checkins)).to be_kind_of Array
    end

    it "returns checkins sorted by created at" do
      expect(devices.send(:gon_index_checkins)[0]["id"]).to eq Checkin.first.id
    end

    it "returns one checkin for each device" do
      FactoryGirl.create(:device, user: user)
      FactoryGirl.create(:checkin, device: Device.last)
      checkins = devices.send(:gon_index_checkins)
      devices_count = Device.joins(:checkins).distinct.all.count
      expect(checkins.length).to eq devices_count
    end
  end

  describe "gon_shared_checkin" do
    it "returns nothing if no checkin present" do
      expect(devices.send(:gon_shared_checkin)).to eq nil
    end

    context "with checkins" do
      let(:devices) { described_class.new(user, { id: device.id }, "shared") }
      before do
        checkins
      end

      it "returns a checkin" do
        expect(devices.send(:gon_shared_checkin)).to be_kind_of Checkin
      end

      it "returns a checkin with fogged attributes if fogged" do
        expect(devices.send(:gon_shared_checkin)["lat"]).to eq Checkin.first.fogged_lat
      end

      it "returns an unfogged checkin if device and checkin unfogged" do
        device.update(fogged: false)
        Checkin.first.update(fogged: false)
        expect(devices.send(:gon_shared_checkin)["lat"]).to eq Checkin.first.lat
      end
    end
  end

  describe "gon_show_checkins" do
    it "returns an ActiveRecord AssociationRelation" do
      expect(devices_show.send(:gon_show_checkins)).to be_kind_of ActiveRecord::Associations::CollectionProxy
    end
  end

  describe "gon_show_checkins_paginated" do
    it "returns an ActiveRecord AssociationRelation" do
      expect(devices_show.send(:gon_show_checkins_paginated)).to be_kind_of ActiveRecord::AssociationRelation
    end

    context "with checkins" do
      before do
        checkins
      end

      it "removes excess attributes" do
        expect(devices_show.send(:gon_show_checkins_paginated)[0]).not_to respond_to(:fogged_lat)
      end
    end
  end

  describe "form_for" do
    it "returns a Device" do
      expect(devices_show.form_for).to be_kind_of Device
    end
  end

  describe "form_path" do
    it "returns show device path" do
      expect(devices_show.form_path).to eq "/users/#{user.url_id}/devices/#{device.id}"
    end
  end

  describe "form_range_filter" do
    let(:date) { 1.week.ago }
    let(:output) { devices_show.form_range_filter("range", date) }

    it "returns a link containing the provided text to get checkins for a certain range" do
      expect(output).to match "range"
    end

    it "returns a link containing the provided range" do
      expect(output).to match date.to_date.to_s
    end
  end
end
