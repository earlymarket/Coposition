require "rails_helper"

describe NotifyAboutCheckin do
  let(:device) { create :device }
  let(:checkin) { create :checkin, device: device }
  let(:friend) { create :user }
  let(:checkin_message) do
    { action: "checkin",
      privilege: "last_only",
      checkin: checkin.as_json.merge("user_id" => device.user.id, "device" => checkin.device.name) }
  end

  subject(:notify_about_checkin) do
    described_class.call(device: device, checkin: checkin)
  end

  before do
    Approval.add_friend(device.user, friend)
    Approval.add_friend(friend, device.user)
    allow(ConnectedList).to receive(:all).and_return [friend.id.to_s]
    allow(device).to receive(:notify_subscribers)
  end

  it "notifies device subscribers" do
    expect(notify_about_checkin.success?).to be_truthy

    expect(device).to have_received(:notify_subscribers).with("new_checkin", checkin)
  end

  it "broadcasts checkin message for friends" do
    expect(ActionCable.server)
      .to receive(:broadcast)
      .with "friends_#{friend.id}", checkin_message

    notify_about_checkin
  end
end
