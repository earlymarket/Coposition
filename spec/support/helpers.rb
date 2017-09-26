module Helpers
  def json_content_type
    { "Content-Type" => "application/json; charset=utf-8" }
  end

  def stub_push_notification
    stub_request(:post, Firebase::Push::FIRE_URL)
      .to_return(body: { "message_id": 1 }.to_json, headers: json_content_type)
  end

  def expect_push_notification(token:, notification:)
    stub_request(:post, Firebase::Push::FIRE_URL)
      .with(body: {
        to: "/topics/#{token}",
        priority: "high",
        notification: notification
      }.to_json)
      .to_return(body: { "message_id": 1 }.to_json, headers: json_content_type)
  end
end
