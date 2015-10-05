require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do
	include ControllerMacros

	describe "POST" do
		it "should POST a checkin without a pre-existing device" do
			checkin_count = Checkin.count
			@demo = {
				checkin: {
						uuid: Faker::Number.number(12),
						lat: Faker::Address.latitude,
						lng: Faker::Address.longitude
					}
				}
			post :create, @demo
			res = response_to_hash
			
			expect(res[:uuid]).to eq @demo[:checkin][:uuid]
			expect(Checkin.count).to be (checkin_count + 1)
		end

	end

end


