require 'rails_helper'

RSpec.describe Checkin, type: :model do
  
  describe "parsing" do

    it "should take a string with a GPS and return an object" do
      @checkin = Checkin.create_from_string(RequestFixture.w_gps)
      expect(@checkin).to eq Checkin.last
    end

  end

end