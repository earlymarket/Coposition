require "rails_helper"

RSpec.describe Users::SendSmoochMessage, type: :interactor do
  subject(:send_context) { described_class.call(user: user, message: message, api: api) }

  let(:user) do
    u = create :user
    d = create :device, user: u
    create :config, device: d, custom: { smoochId: "1" }.to_json
    u
  end
  let(:api) { SmoochApi::ConversationApi.new }
  let(:message) { SmoochApi::MessagePost.new(role: "appMaker", type: "text", text: "Test message") }

  describe "call" do
    context "when given valid params" do
      it "succeeds" do
        allow(api).to receive(:post_message)
        expect(send_context).to be_a_success
      end
    end

    context "when given invalid params" do
      it "fails" do
        expect(send_context).to be_a_failure
      end

      it "provides an alert message" do
        expect(send_context.alert).to match "Unauthorized"
      end
    end
  end
end
