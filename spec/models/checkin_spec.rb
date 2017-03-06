require "rails_helper"

RSpec.describe Checkin, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user: user) }
  let(:checkin) { FactoryGirl.create :checkin, device: device }

  describe "factory" do
    it "creates a valid checkin" do
      expect(checkin).to be_valid
    end

    it "is invalid without a lat" do
      expect(FactoryGirl.build(:checkin, lat: nil)).not_to be_valid
    end

    it "is invalid without a lng" do
      expect(FactoryGirl.build(:checkin, lng: nil)).not_to be_valid
    end
  end

  describe "Associations" do
    it "belongs to user via delegation" do
      expect(checkin.user).to eq user
    end

    it "belongs to device" do
      assc = described_class.reflect_on_association(:device)
      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "callbacks" do
    it "generates values after create" do

    end

    it "fails to generate values after create if no device"

    it "sets edited if lat/lng edited before update" do
    end

    it "doesn't set edited if lat/lng not edited before update" do
    end
  end

  describe "Scopes" do
    it "is sorted by created_at by default" do
    end

    context "since" do
      it "returns checkins since a certain datetime" do
      end
    end

    context "before" do
      it "returns checkins before a certain datetime" do
      end
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      %i(assign_values update_output assign_output_to_fogged assign_output_to_unfogged reverse_geocode!
         reverse_geocoded? switch_fog set_edited nearest_city).each do |method|
        it { expect(checkin).to respond_to(method) }
      end
    end

    context "assign_values" do
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(limit_returned_checkins near_to since_time on_date unique_places_only
         hash_group_and_count_by percentage_increase to_csv to_gpx to_geojson).each do |method|
        it { expect(Checkin).to respond_to(method) }
      end
    end

    context "limit_returned_checkins" do
    end
  end
end
