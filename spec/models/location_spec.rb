require "rails_helper"

RSpec.describe Location, type: :model do
  let!(:location) { FactoryGirl.create(:location) }
  let!(:second_location) { FactoryGirl.create(:location, created_at: Date.yesterday) }

  describe "factory" do
    it "creates a valid location" do
      location = FactoryGirl.build(:location)
      expect(location).to be_valid
    end
  end

  describe "validation" do
    it "is not valid without lat" do
      location = Location.create(lng: -0.513069)

      expect(location).not_to be_valid
    end

    it "is not valid without lng" do
      location = Location.create(lat: 51.588330)

      expect(location).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a device" do
      assc = described_class.reflect_on_association(:device)

      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      %i(reverse_geocode! reverse_geocoded?).each do |method|
        it { expect(location).to respond_to(method) }
      end
    end

    context "reverse_geocode!" do
      it "changes the location address" do
        expect { location.reverse_geocode! }.to change { location.address }
      end

      it "does nothing if address present" do
        location.reverse_geocode!

        expect { location.reverse_geocode! }.not_to change { location.address }
      end
    end

    context "reverse_geocoded?" do
      it "returns false if address not present" do
        expect(location.reverse_geocoded?).to eq false
      end

      it "returns true if address present" do
        location.reverse_geocode!

        expect(location.reverse_geocoded?).to eq true
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(limit_returned_locations near_to most_frequent).each do |method|
        it { expect(Location).to respond_to(method) }
      end
    end

    context "limit_returned_locations" do
      it "returns all locations if multiple devices argument" do
        result = Location.limit_returned_locations(multiple_devices: true)

        expect(result).to eq Location.all.distinct
      end

      it "returns paginated locations if not multiple devices" do
        result = Location.limit_returned_locations(multiple_devices: false, per_page: 1, page: 1)

        expect(result).to eq [Location.distinct[0]]
      end
    end

    context "near_to" do
      it "returns all locations unless truthy argument provided" do
        expect(Location.near_to(nil)).to eq Location.all
      end

      it "returns an array of locations" do
        expect(Location.near_to("51.588330, -0.513069")).to be_kind_of(ActiveRecord::Relation)
      end

      it "returns locations near lat/lng provided" do
        loc = FactoryGirl.create(:location, lat: 10, lng: 10)

        expect(Location.near_to("10, 10")).to eq [loc]
      end
    end

    context "most_frequent" do
      it "returns all locations without most_frequent arg" do
      end
      
      it "returns 10 most visited locations" do
      end
    end
  end
end
