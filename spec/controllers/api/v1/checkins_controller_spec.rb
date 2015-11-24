require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
  include ControllerMacros

  describe "POST" do
    it "should POST a checkin without a pre-existing device, and create one" do
      checkin_count = Checkin.count
      device_count = Device.count
      @demo = {
        checkin: {
            uuid: Faker::Number.number(12),
            lat: Faker::Address.latitude,
            lng: Faker::Address.longitude
          }
        }

      post :create, @demo
      res = res_hash
      
      expect(res[:uuid]).to eq @demo[:checkin][:uuid]
      expect(Checkin.count).to be (checkin_count + 1)
      expect(Device.count).to be (device_count + 1)
    end

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
      res = res_hash
      
      expect(res[:uuid]).to eq @demo[:checkin][:uuid]
      expect(Checkin.count).to be (checkin_count + 1)
      expect(Device.find_by(uuid: uuid)).to_not be nil
    end

  end

end


