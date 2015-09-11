require 'rails_helper'

RSpec.describe Redbox::CheckinsController, type: :controller do

  describe "posting" do
    it "should POST to the server with a normal string" do
      post "/redbox/checkins", RequestFixture.w_gps
      expect(last_response.ok?).to be true

      # Don't send entire obj back due to GPRS limits
      expect(last_response.body).to eq "ok"
    end
  end

end
