require "rails_helper"

RSpec.describe Api::V1::UsersController, type: :controller do
  include ControllerMacros

  let(:dev) { create :developer }
  let(:user) { create :user }

  describe "#show" do
    context "without an API key" do
      it "renders status 401 with message" do
        get :show, params: { id: user.id, format: :json }

        expect(response.status).to eq 401
        expect(res_hash[:error]).to eq "No valid API Key"
      end
    end

    context "with a correct API key" do
      before do
        request.headers["X-Api-Key"] = dev.api_key
      end

      it "rejects an unapproved user" do
        get :show, params: { id: user.id, format: :json }

        expect(response.status).to eq 401
      end

      context "when developer is approved" do
        before do
          Approval.link(user, dev, "Developer")
          Approval.accept(user, dev, "Developer")
        end

        it "assigns public profile of User.id(:id) to @user" do
          get :show, params: { id: user.id, format: :json }

          expect(assigns(:user)).to eq(user)
          expect(assigns(:user).connection_code). to eq(nil)
        end

        context "when request from coposition app" do
          let(:dev) { create :developer, api_key: Rails.application.secrets.mobile_app_key }
          let(:application) { double "application" }
          let(:access_token) { double "access_token", token: "token" }

          before do
            request.headers["X-Secret-App-Key"] = dev.api_key

            allow(dev).to receive(:oauth_application) { application }
            allow(Doorkeeper::AccessToken).to receive(:where) { Doorkeeper::AccessToken }
            allow(Doorkeeper::AccessToken).to receive(:first) { access_token }

            get :show, params: { id: user.id, format: :json }
          end

          it "assigns private profile of User.id(:id) to @user" do
            expect(assigns(:user)).to eq(user)
            expect(assigns(:user).connection_code). to eq(user.connection_code)
          end

          it "returns copo_app_access_token with other serializable fields" do
            expect(res_hash[:user]["copo_app_access_token"]).to eq "token"
          end
        end
      end

      it "returns 404 and an error message if user does not exist" do
        get :show, params: { id: 1000, format: :json }

        expect(response.status).to eq 404
        expect(res_hash[:error]).to match "Couldn't find User with 'id'=1000"
      end
    end
  end

  describe "#index" do
    before do
      request.headers["X-Api-Key"] = dev.api_key
      Approval.link(user, dev, "Developer")
      Approval.accept(user, dev, "Developer")
    end

    it "returns a list of a developers approved users" do
      get :index, params: { format: :json }

      expect(assigns(:users)).to eq([user])
    end
  end

  describe "#auth" do
    context "with a valid webhook key in header" do
      before do
        request.headers["X-Authentication-Key"] = user.webhook_key
      end

      it "returns status 204 and json message 'success'" do
        get :auth

        expect(response.status).to eq 204
        expect(res_hash[:message]).to eq "Success"
      end
    end

    context "without a valid webhook key in header" do
      it "returns status 400 and json message 'Invalid webhook key supplied'" do
        get :auth

        expect(response.status).to eq 400
        expect(res_hash[:error]).to eq "Invalid webhook key supplied"
      end
    end
  end
end
