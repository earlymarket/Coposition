require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "factory" do
    it "creates a valid location" do
      location = FactoryGirl.build(:location)
      expect(location).to be_valid
    end
  end

  describe "validation" do
    it "is not valid without lat" do
      location = Location.create(lng: -0.513069)
      expect(location).to_not be_valid
    end
    it "is not valid without lng" do
      location = Location.create(lat: 51.588330)
      expect(location).to_not be_valid
    end
  end

  describe "associations" do
    it "belongs to a user" do
      assc = described_class.reflect_on_association(:user)
      expect(assc.macro).to eq :belongs_to
    end
  end

end
