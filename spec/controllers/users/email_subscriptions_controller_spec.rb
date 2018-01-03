require "rails_helper"

RSpec.describe Users::EmailSubscriptionsController, type: :controller do
  let(:user) { create :user }
  let(:email_subscription) { create :email_subscription, user: user }
  let(:unsub_id) { Rails.application.message_verifier(:unsubscribe).generate(user.id) }
  let(:unsubscribe) { put :update, params: { user_id: user.id, id: email_subscription.id, email_subscription: { device_inactivity: false } } }

  describe "GET #unsubscribe" do
    it "returns http success" do
      get :unsubscribe, params: { user_id: user.id, id: unsub_id }
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
        expect { unsubscribe }.to change { EmailSubscription.find(email_subscription.id).device_inactivity }.to false
      end
    end
  end
end
