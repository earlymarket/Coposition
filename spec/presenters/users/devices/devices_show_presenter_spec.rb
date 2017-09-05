require "rails_helper"

describe ::Users::Devices::DevicesShowPresenter do
  subject(:show_presenter) { described_class.new(user, id: device.id) }
  let(:user) { create(:user) }
  let(:device) { create(:device, user_id: user.id) }
  let(:checkins) do
    create(:checkin, device_id: device.id)
    create(:checkin, device_id: device.id).reverse_geocode!
    create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(user device checkins filename date_range show_gon form_for form_path form_range_filter).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "user" do
    it "returns user" do
      expect(show_presenter.user).to eq user
    end
  end

  describe "device" do
    it "returns a device" do
      expect(show_presenter.device).to be_kind_of Device
    end
  end

  describe "checkins" do
    it "returns nil if no download params" do
      expect(show_presenter.checkins).to be_nil
    end

    it "returns checkins converted to param provided" do
      checkins
      show_presenter = described_class.new(user, id: device.id, download: "gpx")
      expect(show_presenter.checkins).to eq device.checkins.to_gpx
    end
  end

  describe "filename" do
    it "returns nil if no download params" do
      expect(show_presenter.filename).to be_nil
    end

    it "returns a string" do
      show_presenter = described_class.new(user, id: device.id, download: "gpx")
      expect(show_presenter.filename).to be_kind_of String
    end
  end

  describe "date_range" do
    before { checkins }

    it "returns date of first and last check-in being shown on first load" do
      show_presenter = described_class.new(user, id: device.id, first_load: true)
      expect(show_presenter.date_range).to eq from: Checkin.last.created_at.beginning_of_day, to: Checkin.first.created_at.end_of_day
    end

    it "returns date selected if params provided" do
      show_presenter = described_class.new(user, id: device.id, from: Date.yesterday.strftime, to: Date.today.strftime)
      expect(show_presenter.date_range).to eq from: Date.yesterday.beginning_of_day, to: Date.today.end_of_day
    end

    it "returns nil range if no date range" do
      show_presenter = described_class.new(user, id: device.id)
      expect(show_presenter.date_range).to eq from: nil, to: nil
    end
  end

  describe "show_gon" do
    it "returns a hash" do
      expect(show_presenter.show_gon).to be_kind_of Hash
    end

    it "calls gon_show_checkins" do
      allow(show_presenter).to receive(:gon_show_checkins).and_return device.checkins
      show_presenter.show_gon
      expect(show_presenter).to have_received(:gon_show_checkins).at_least(1).times
    end
  end

  describe "form_for" do
    it "returns a Device" do
      expect(show_presenter.form_for).to be_kind_of Device
    end
  end

  describe "form_path" do
    it "returns show device path" do
      expect(show_presenter.form_path).to eq "/users/#{user.url_id}/devices/#{device.id}"
    end
  end

  describe "form_range_filter" do
    let(:date) { 1.week.ago }
    let(:output) { show_presenter.form_range_filter("range", date) }

    it "returns a link containing the provided text to get checkins for a certain range" do
      expect(output).to match "range"
    end

    it "returns a link containing the provided range" do
      expect(output).to match date.to_date.to_s
    end
  end

  describe "gon_show_checkins" do
    it "returns an ActiveRecord AssociationRelation" do
      expect(show_presenter.send(:gon_show_checkins)).to be_kind_of ActiveRecord::Associations::CollectionProxy
    end
  end

  describe "gon_show_checkins_paginated" do
    it "returns an ActiveRecord AssociationRelation" do
      expect(show_presenter.send(:gon_show_checkins_paginated)).to be_kind_of ActiveRecord::AssociationRelation
    end

    context "with checkins" do
      it "removes excess attributes" do
        checkins
        expect(show_presenter.send(:gon_show_checkins_paginated)[0]).not_to respond_to(:fogged_lat)
      end
    end
  end
end
