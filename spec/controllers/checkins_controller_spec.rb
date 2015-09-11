require 'rails_helper'

RSpec.describe Redbox::CheckinsController, type: :controller do

  describe "posting" do
    it "should POST to the server with a normal string" do
      post :create, data: RequestFixture.w_gps
      expect(response.ok?).to be true

      # Don't send entire obj back due to GPRS limits
      expect(response.body).to eq "ok"
    end
  end

end
