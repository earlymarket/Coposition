require "rails_helper"

RSpec.describe NoCity, type: :model do
  subject(:no_city) { NoCity.new }

  describe "public class methods" do
    context "responds to its methods" do
      %i(nil? latitude longitude name country_code).each do |method|
        it { is_expected.to respond_to method }
      end
    end

    context "nil?" do
      it "returns true" do
        expect(no_city.nil?).to be true
      end
    end

    context "latitude" do
      it "returns nil" do
        expect(no_city.latitude).to be nil
      end
    end

    context "longitude" do
      it "returns nil" do
        expect(no_city.longitude).to be nil
      end
    end

    context "name" do
      it "returns 'No nearby cities'" do
        expect(no_city.name).to eq "No nearby cities"
      end
    end

    context "country_code" do
      it "returns 'No Country'" do
        expect(no_city.country_code).to eq "No Country"
      end
    end
  end
end
