require 'rails_helper'

RSpec.describe SettingsController, type: :controller do

  describe "GET #unsubscribe" do
    it "returns http success" do
      get :unsubscribe
      expect(response).to have_http_status(:success)
    end
  end

end
