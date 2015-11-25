#       # REDBOXTODO
# require 'rails_helper'

# RSpec.describe Redbox::CheckinsController, type: :controller do

#   describe "posting" do
#     it "should POST to the server with a normal string" do
#       post :create, data: RequestFixture.new.w_gps
#       expect(response.ok?).to be true

#       # Don't send entire obj back due to GPRS limits
#       expect(response.body).to eq "ok"
#     end

#     it "should POST to the server without string" do
#       post :create, data: RequestFixture.new.no_gps
#       expect(response.ok?).to be true

#       # Don't send entire obj back due to GPRS limits
#       expect(response.body).to eq "ok"
#     end

#     it "should GET a range" do
#       # @chk1 = RedboxCheckin.create_from_string(RequestFixture.new.w_gps)
#       # @chk2 = RedboxCheckin.create_from_string(RequestFixture.new.w_gps)
#       # @chk3 = RedboxCheckin.create_from_string(RequestFixture.new.w_gps)
#       # @chk4 = RedboxCheckin.create_from_string(RequestFixture.new.w_gps)
#       # post :show, {id: @chk1.id, range: 3}
#       # expect(response.ok?).to be true

#       # expect(response.body).to eq [@chk1, @chk2, @chk3].to_json
#     end
#   end

# end
