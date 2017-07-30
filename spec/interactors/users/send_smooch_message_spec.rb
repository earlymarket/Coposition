require "rails_helper"

RSpec.describe Users::SendSmoochMessage, type: :interactor do
  subject(:send_context) { described_class.call(user: user, message: message, api: api) }

  let(:user) do
    u = create :user
    d = create :device, user: u
    create :config, device: d, custom: { smoochId: "1" }
    u
  end
  let(:api) { SmoochApi::ConversationApi.new }
  let(:message) { SmoochApi::MessagePost.new(role: "appMaker", type: "text", text: "Test message") }

  describe "call" do
    context "when given valid params" do
      it "succeeds" do
        expect(send_context).to be_a_success
      end
    end
  end
end
