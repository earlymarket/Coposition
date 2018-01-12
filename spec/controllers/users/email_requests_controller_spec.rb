require "rails_helper"

RSpec.describe Users::EmailRequestsController, type: :controller do
  include ControllerMacros

  let(:user) { create_user }
  let(:email_request) { create :email_request }
  let(:params) { { id: email_request.id, user_id: user.id, format: :js } }

  describe "DELETE #destroy" do
    it "destroys the email request" do
      email_request
      expect { delete :destroy, params: params }.to change { EmailRequest.count }.by -1
    end

    it "redirects to the update page" do
      expect(delete :destroy, params: params).to render_template 'users/approvals/update'
    end
  end
end
