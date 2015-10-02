require 'rails_helper'

RSpec.describe Api::V1::CheckinsController, type: :controller do

	describe "POST" do

		it "should POST a checkin without a pre-existing device" do
			post :create, {
				checkin: {
					uuid: Faker::Number.number(12),
					lat: Faker::Address.latitude,
					lng: Faker::Address.longitude
				}
			}
			binding.pry

		end

	end

end
