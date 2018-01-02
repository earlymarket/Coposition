require "rails_helper"

RSpec.describe SettingsController, type: :controller do
  let(:user) { create :user }
  let(:unsub_id) { Rails.application.message_verifier(:unsubscribe).generate(user.id) }
  let(:unsubscribe) { put :update, params: { id: user.id, user: { subscription: "inactivity" } } }

  describe "GET #unsubscribe" do
    it "returns http success" do
      get :unsubscribe, params: { id: unsub_id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    context "with subscription set to all" do
      it "returns http redirect" do
        unsubscribe
        expect(response).to have_http_status(:redirect)
      end

      it "returns a flash message" do
        unsubscribe
        expect(flash[:notice]).to eq "Subscription settings updated"
      end

      it "changes subscription to inactivity" do
        expect { unsubscribe }.to change { User.find(user.id).subscription }.to "inactivity"
      end
    end
  end
end
