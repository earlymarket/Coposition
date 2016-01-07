require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros

  describe "POST" do
    it "should POST a checkin with a pre-existing device" do
      uuid = Faker::Number.number(12)

      checkin_count = Checkin.count

      device = FactoryGirl::create(:device)
      device.uuid = uuid
      device.save!

      @demo = {
        checkin: {
            uuid: uuid,
            lat: Faker::Address.latitude,
            lng: Faker::Address.longitude
          }
        }

      post :create, @demo
      
      expect(res_hash[:uuid]).to eq @demo[:checkin][:uuid]
      expect(Checkin.count).to be(checkin_count + 1)
      expect(Device.find_by(uuid: uuid)).to_not be nil
    end

    it "should return 400 if you POST a device with missing parameters" do
      @demo = {
        checkin: {
            uuid: Faker::Number.number(12),
            lat: Faker::Address.latitude
            # lng: Faker::Address.longitude
          }
        }
      post :create, @demo
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq('message' => 'You must provide a UUID, lat and lng')
    end

  end

end


