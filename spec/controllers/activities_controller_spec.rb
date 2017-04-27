require "rails_helper"

RSpec.describe ActivitiesController, type: :controller do
  include ControllerMacros
  let(:user) do
    create_user
    User.last.update(admin: true)
    User.last
  end

  describe "GET #index" do
    it "returns http success if admin" do
      user
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns http failure if not admin" do
      get :index
      expect(response).to have_http_status(302)
    end
  end
end
