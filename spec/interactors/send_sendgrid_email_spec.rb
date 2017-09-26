require "rails_helper"

RSpec.describe SendSendgridEmail, type: :interactor do
  subject(:send_context) do
    described_class.call(
      to: "tom@email.com",
      subject: "test email",
      id: "64b3b8c9-12ae-49bc-9983-2ac3e507ac0d",
      substitutions: [{ key: "key", value: "value" }],
      content: "content"
    )
  end

  describe "call" do
    it "succeeds" do
      expect(send_context).to be_a_success
    end

    it "sends an email" do
      expect(send_context.response.status_code).to eq "200"
    end

    it "fails with an invalid id" do
      send_context = described_class.call(
        to: "tom@email.com", subject: "test email", id: "10", content: "content",
        substitutions: [{ key: "key", value: "value" }]
      )
      expect(send_context).to be_a_failure
    end
  end
end
