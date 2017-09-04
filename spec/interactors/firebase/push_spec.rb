require "rails_helper"

describe Firebase::Push do
  let(:user) do
    create :user,
      notification_token: "1496249902a1edd9a57c8b5554b745e38b20721f01"
  end
  let(:notification) do
    {
      body: "Coposition test message",
      title: "Coposition check-in"
    }
  end

  let(:expected_body) do
    {
      to: "/topics/1496249902a1edd9a57c8b5554b745e38b20721f01",
      priority: "high",
      notification: {
        body: "Coposition test message",
        title: "Coposition check-in"
      }
    }.to_json
  end

  let(:expected_headers) do
    {
      "Content-Type" => "application/json",
      "Authorization" => "key=#{Rails.app_config.firebase_server_key}"
    }
  end

  let(:response) { { "message_id": 1 }.to_json }

  before do
    stub_request(:post, "https://fcm.googleapis.com/fcm/send")
      .with(body: expected_body, headers: expected_headers)
      .to_return(body: response, headers: json_content_type)
  end

  it "sends push notification" do
    described_class.call(topic: user.notification_token, notification: notification)
  end
end