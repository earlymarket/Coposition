require "rails_helper"

RSpec.describe Api::V1::Users::ApprovalsController, type: :controller do
  include ControllerMacros

  let(:user) { create :user }
  let(:developer) { create :developer }
  let(:second_user) { create :user }
  let(:apprvl) { create(:approval, user: user, approvable_id: developer.id, approvable_type: "Developer") }
  let(:params) { { user_id: user.id, format: :json } }
  let(:dev_approval_create_params) do
    params.merge(approval: { approvable: developer.company_name, approvable_type: "Developer" })
  end
  let(:friend_approval_create_params) do
    params.merge(approval: { approvable: second_user.email, approvable_type: "User" })
  end
  let(:friend_approval_invite_params) do
    params.merge(approval: { approvable: "example@email.com", approvable_type: "User" })
  end
  let(:approval_destroy_params) { params.merge(id: apprvl.id) }
  let(:approval_update_params) { approval_destroy_params.merge(approval: { status: "accepted" }) }

  before do
    request.headers["X-Api-Key"] = developer.api_key
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end

  describe "a user" do
    before do
      request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
    end

    context "when post to create" do
      it "is able to create a developer approval" do
        post :create, params: dev_approval_create_params
        expect(Approval.where(approvable: developer, status: "accepted", user: user)).to exist
      end

      it "is able to create a user approval request" do
        friend_approval_create_params
        approval_count = Approval.count
        post :create, params: friend_approval_create_params
        expect(Approval.count).to eq approval_count + 2
        expect(Approval.where(user: second_user, approvable: user, status: "requested")).to exist
      end

      it "is able to invite a user to join coposition" do
        post :create, params: friend_approval_invite_params
        expect(EmailRequest.where(user_id: user.id, email: "example@email.com")).to exist
        expect(res_hash[:error]).to match("User not signed up with Coposition, invite email sent!")
      end

      it "is not able to submit another request to same user" do
        Approval.link(user, second_user, "User")
        approval_count = Approval.count
        post :create, params: friend_approval_create_params
        expect(Approval.count).to eq approval_count
        expect(Approval.where(approvable_type: "User", status: "accepted")).not_to exist
        expect(res_hash[:error]).to match("Friend request already sent")
      end

      it "approves a developer request" do
        request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
        Approval.link(user, developer, "Developer")
        expect(Approval.where(user: user, approvable: developer, status: "developer-requested")).to exist
        post :create, params: dev_approval_create_params
        expect(Approval.where(user: user, approvable: developer, status: "accepted")).to exist
      end

      it "is not able to create an approval for a non-existant developer" do
        post :create, params: params.merge(approval: { approvable: "Fake company", approvable_type: "Developer" })
        expect(res_hash[:error]).to match("Developer not found")
      end

      it "approves a friend request" do
        request.headers["X-Secret-App-Key"] = "this-is-a-mobile-app"
        Approval.link(second_user, user, "User")
        expect(user.approval_for(second_user).status).to eq "requested"
        post :create, params: friend_approval_create_params
        expect(user.approval_for(second_user).status).to eq "accepted"
        expect(second_user.approval_for(user).status).to eq "accepted"
      end
    end

    context "making a request to #update" do
      it "is able to approve a developer approval request" do
        put :update, params: approval_update_params
        expect(user.approval_for(developer).status).to eq "accepted"
      end

      it "returns the new approval" do
        put :update, params: approval_update_params
        expect(res_hash[:id]).to eq user.approval_for(developer).id
      end

      it "is able to approve a user approval request" do
        Approval.link(user, second_user, "User")
        expect(user.friends.include?(second_user)).to be false
        put :update, params: approval_update_params.merge(id: Approval.find_by(user: user, approvable_type: "User").id)
        expect(res_hash[:id]).to eq user.approval_for(second_user).id
        expect(second_user.friends.include?(user)).to be true
        expect(user.friends.include?(second_user)).to be true
      end

      it "is not able to approve approval belonging to another user" do
        put :update, params: approval_update_params.merge(user_id: second_user.id)
        expect(res_hash[:error]).to match("Approval does not exist")
        expect(user.approved?(developer)).to be false
      end

      it "is not able to approve an approval that does not belong to you" do
        second_user.approvals.create(approvable_id: developer.id)
        put :update, params: approval_update_params.merge(id: second_user.approvals.first.id)
        expect(res_hash[:error]).to match("does not exist")
        expect(response.status).to be 404
        expect(user.approved?(developer)).to be false
      end
    end

    context "making a request to #destroy" do
      it "returns response with status 200" do
        delete :destroy, params: approval_destroy_params
        expect(response.status).to be 200
      end

      it "renders message" do
        delete :destroy, params: approval_destroy_params
        expect(res_hash[:message]).to eq "Approval Destroyed"
      end

      it "returns an error message if approval does not exist" do
        delete :destroy, params: params.merge(id: "wrong")
        expect(res_hash[:error]).to eq "Approval does not exist"
      end

      it "renders status 404 if approval does not exist" do
        delete :destroy, params: params.merge(id: "wrong")
        expect(response.status).to be 404
      end
    end
  end

  describe "get #index" do
    before do
      Approval.link(user, developer, "Developer")
      Approval.link(user, second_user, "User")
      Approval.accept(user, second_user, "User")
    end

    it "gets a list of a users approvals" do
      get :index, params: params
      expect(res_hash.length).to eq Approval.where(user: user).count
      expect(res_hash.first["user_id"]).to eq user.id
    end

    it "gets a list of a users accepted friend approvals" do
      get :index, params: params.merge(type: "friends")
      expect(res_hash.length).to eq Approval.where(user: user, approvable_type: "User").count
      expect(res_hash.first["status"]).to eq "accepted"
      expect(res_hash.first["approvable_type"]).to eq "User"
    end
  end
end
