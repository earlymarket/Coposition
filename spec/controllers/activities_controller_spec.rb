require "rails_helper"

RSpec.describe ActivitiesController, type: :controller do
  include ControllerMacros
  let(:user) do
    create_user
    User.last.update(admin: true)
    User.last
  end

  describe "GET #index" do
    it "returns http failure if user is not admin" do
      get :index
      expect(response).to have_http_status(302)
    end

    context "when admin user" do
      before { user }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns activities presenter" do
        get :index
        expect(assigns(:activities_presenter)).to be_kind_of ActivitiesPresenter
      end
    end
  end
end
