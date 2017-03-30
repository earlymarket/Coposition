require "rails_helper"

describe NotifyAboutCheckin do
  subject(:notify_about_checkin) { described_class.call(device: device, checkin: checkin) }
  let(:device) { create :device }
  let(:checkin) { create :checkin, device: device }
  let(:friend) { create :user }
  let(:checkin_message) do
    { action: "checkin",
      privilege: "last_only",
      checkin: checkin.as_json.merge("user_id" => device.user.id, "device" => checkin.device.name) }
  end

  before do
    Approval.add_friend(device.user, friend)
    Approval.add_friend(friend, device.user)
    allow(ConnectedList).to receive(:all).and_return [friend.id.to_s]
    allow(device).to receive(:notify_subscribers)
    allow(ActionCable.server)
      .to receive(:broadcast)
      .with("friends_#{friend.id}", checkin_message)
      .and_return "ok"
  end

  it "notifies device subscribers" do
    expect(notify_about_checkin.success?).to be_truthy

    expect(device).to have_received(:notify_subscribers).with("new_checkin", checkin)
  end

  it "broadcasts checkin message for friends" do
    notify_about_checkin
    expect(ActionCable.server).to have_received(:broadcast)
  end
end
