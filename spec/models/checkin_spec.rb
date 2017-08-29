require "rails_helper"

RSpec.describe Checkin, type: :model do
  let(:user) { create(:user) }
  let(:device) { create(:device, user: user) }
  let(:checkin) { create :checkin, device: device }

  describe "factory" do
    it "creates a valid checkin" do
      expect(checkin).to be_valid
    end

    it "is invalid without a lat" do
      expect(build(:checkin, lat: nil)).not_to be_valid
    end

    it "is invalid without a lng" do
      expect(build(:checkin, lng: nil)).not_to be_valid
    end

    it "is invalid with an invalid lat" do
      expect(build(:checkin, lat: 100)).not_to be_valid
    end

    it "is invalid with an invalid lng" do
      expect(build(:checkin, lng: -190)).not_to be_valid
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
    context "after_create" do
      let(:new_checkin) { build(:checkin, device: nil) }

      it "generates values after create" do
        allow(new_checkin).to receive(:assign_values)
        new_checkin.device = device
        new_checkin.save
        expect(new_checkin).to have_received(:assign_values)
      end

      it "fails to generate values after create if no device" do
        expect { new_checkin.save }.to raise_error(RuntimeError)
      end
    end

    context "before_update" do
      it "sets edited if lat/lng edited before update" do
        allow(checkin).to receive(:set_edited)
        checkin.update(lat: checkin.lat + 1)
        expect(checkin).to have_received(:set_edited)
      end

      it "doesn't set edited if lat/lng not edited before update" do
        allow(checkin).to receive(:set_edited)
        checkin.update(fogged: false)
        expect(checkin).not_to have_received(:set_edited)
      end
    end
  end

  describe "Scopes" do
    let(:new_checkin) { create(:checkin, device: device, created_at: 1.day.ago) }

    before do
      checkin
      new_checkin
    end

    it "is sorted by created_at by default" do
      expect(Checkin.last).to eq new_checkin
    end

    context "since" do
      it "returns checkins since a certain datetime" do
        expect(Checkin.since(1.hour.ago)).to eq [checkin]
      end
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      %i(assign_values update_output assign_output_to_fogged assign_output_to_unfogged reverse_geocode!
         reverse_geocoded? set_edited nearest_city).each do |method|
        it { expect(checkin).to respond_to(method) }
      end
    end

    context "assign_values" do
      it "assigns several new values for a checkin" do
        expect { checkin.assign_values }.to change { checkin.fogged_lat }
      end

      it "calls nearest_city" do
        allow(checkin).to receive(:nearest_city).and_return NoCity.new
        checkin.assign_values
        expect(checkin).to have_received(:nearest_city)
      end
    end

    context "update_output" do
      it "calls assign_output_to_fogged if checkin fogged" do
        allow(checkin).to receive(:assign_output_to_fogged)
        checkin.update_output
        expect(checkin).to have_received(:assign_output_to_fogged)
      end

      it "calls assign_output_to_unfogged if checkin unfogged" do
        allow(checkin).to receive(:assign_output_to_unfogged)
        checkin.fogged = false
        checkin.update_output
        expect(checkin).to have_received(:assign_output_to_unfogged)
      end
    end

    context "assign_output_to_fogged" do
      it "assigns output attributes to fogged attributes" do
        checkin.update(output_lat: nil)
        expect { checkin.assign_output_to_fogged }.to change { checkin.output_lat }.to checkin.fogged_lat
      end
    end

    context "assign_output_to_unfogged" do
      it "assigns output attributes to unfogged attributes" do
        checkin.update(output_lat: nil)
        expect { checkin.assign_output_to_unfogged }.to change { checkin.output_lat }.to checkin.lat
      end

      it "assigns output_city to fogged_city if no city present" do
        checkin.update(city: nil, fogged_city: "London")
        expect { checkin.assign_output_to_unfogged }.to change { checkin.output_city }.to checkin.fogged_city
      end
    end

    context "reverse_geocode!" do
      it "returns a checkin" do
        expect(checkin.reverse_geocode!).to be_kind_of(Checkin)
      end

      it "geocodes an un-geocoded checkin" do
        allow(checkin).to receive(:reverse_geocode)
        checkin.reverse_geocode!
        expect(checkin).to have_received(:reverse_geocode)
      end
    end

    context "reverse_geocoded?" do
      it "returns false if checkin not geocoded" do
        expect(checkin.reverse_geocoded?).to eq false
      end

      it "returns true if checkin geocoded" do
        checkin.reverse_geocode!
        expect(checkin.reverse_geocoded?).to eq true
      end
    end

    context "set_edited" do
      it "updates edited attribute to true" do
        expect { checkin.set_edited }.to change { checkin.edited }.from(false).to(true)
      end
    end

    context "nearest_city" do
      it "returns a city" do
        expect(checkin.nearest_city).to be_kind_of(NoCity)
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(limit_returned_checkins near_to since_time on_date unique_places_only
         hash_group_and_count_by percentage_increase to_csv to_gpx to_geojson).each do |method|
        it { expect(Checkin).to respond_to(method) }
      end
    end

    let(:second_checkin) { create :checkin, device: device, created_at: 1.week.ago }

    before do
      checkin
      second_checkin
    end

    context "limit_returned_checkins" do
      it "returns all checkins if index and multiple devices argument" do
        result = Checkin.limit_returned_checkins(action: "index", multiple_devices: true)
        expect(result).to eq [checkin, second_checkin]
      end

      it "returns paginated checkins if index but not multiple devices" do
        result = Checkin.limit_returned_checkins(action: "index", multiple_devices: false, page: 2, per_page: 1)
        expect(result).to eq [second_checkin]
      end

      it "returns one checkin if not index and multiple devices" do
        result = Checkin.limit_returned_checkins(action: "last")
        expect(result).to eq [checkin]
      end
    end

    context "near_to" do
      it "returns all checkins unless truthy argument provided" do
        expect(Checkin.near_to(nil)).to eq Checkin.all
      end

      it "returns an array of checkins" do
        expect(Checkin.near_to("51.588330, -0.513069")).to be_kind_of(ActiveRecord::Relation)
      end

      it "returns checkins near lat/lng provided" do
        checkin.update(lat: 10)
        expect(Checkin.near_to("51.588330, -0.513069")).to eq [second_checkin]
      end
    end

    context "since_time" do
      it "returns all checkins unless truthy arguments provided" do
        expect(Checkin.since_time(nil, nil)).to eq Checkin.all
      end

      it "returns all checkins created since a certain amount of time ago" do
        expect(Checkin.since_time(1, 'day')).to eq [checkin]
      end
    end

    context "on_date" do
      it "returns all checkins unless truthy argument provided" do
        expect(Checkin.on_date(nil)).to eq Checkin.all
      end

      it "returns all checkins created on a certain date" do
        expect(Checkin.on_date(1.week.ago.to_s)).to eq [second_checkin]
      end
    end

    context "unique_places_only" do
      it "returns all checkins unless truthy argument provided" do
        expect(Checkin.unique_places_only(nil)).to eq Checkin.all
      end

      it "returns most recent checkin from each unique location" do
        expect(Checkin.unique_places_only(true)).to eq [checkin]
      end
    end

    context "hash_group_and_count_by" do
      it "returns an array" do
        expect(Checkin.hash_group_and_count_by(:device_id)).to be_kind_of(Array)
      end

      it "returns the number of unique checkins grouped by a certain attribute for each group" do
        expect(Checkin.hash_group_and_count_by(:device_id)[0]).to eq [device.id, device.checkins.count]
      end
    end

    context "percentage_increase" do
      it "returns nothing if no 'older' checkins as defined by time_range" do
        expect(Checkin.percentage_increase("month")).to eq nil
      end

      it "returns 0.0 if checked in the same amount" do
        expect(Checkin.percentage_increase("week")).to eq 0.0
      end
    end

    context "to_download methods" do
      %i[to_csv to_gpx to_geojson].each do |method|
        it "returns a string" do
          expect(Checkin.send(method)).to be_kind_of(String)
        end
      end
    end
  end
end
