require "rails_helper"

describe RequestCheckin do
  subject(:request_checkin) { described_class.call(current_user: user, id: friend.id) }
  let(:user) { create :user }
  let(:friend) { create :user }
  let(:message) { "#{user.username} has requested a location update from you" }
  let(:request_message) do
    { action: "request_checkin",
      message: message }
  end
  let(:request_notification) do
    { topic: friend.id,
      notification: {
        body: message,
        title: "Check-in request"
      } }
  end

  before do
    allow(ConnectedList).to receive(:all).and_return [friend.id.to_s]
    allow(ActionCable.server)
      .to receive(:broadcast)
      .with("friends_#{friend.id}", request_message)
      .and_return "ok"
    allow(Firebase::Push)
      .to receive(:call)
      .with(request_notification)
  end

  it "broadcasts request message for friend" do
    request_checkin
    expect(ActionCable.server).to have_received(:broadcast)
  end

  it "calls firebase push" do
    request_checkin
    expect(Firebase::Push).to have_received(:call)
  end
end
