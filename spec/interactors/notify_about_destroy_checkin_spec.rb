require "rails_helper"

describe NotifyAboutDestroyCheckin do
  let(:device) { create :device }
  let(:checkin) { create :checkin, device: device }
  let(:friend) { create :user }
  let(:destroy_checkin_message) do
    checkin
    new_c = device.safe_checkin_info_for(permissible: friend, action: "last", type: "address")[0].as_json
    { action: "destroy", checkin: checkin.as_json, new: new_c.merge("device" => checkin.device.name) }
  end

  before do
    Approval.add_friend(device.user, friend)
    Approval.add_friend(friend, device.user)
    allow(ConnectedList).to receive(:all).and_return [friend.id.to_s]
    allow(ActionCable.server)
      .to receive(:broadcast)
      .with("friends_#{friend.id}", destroy_checkin_message)
      .and_return "ok"
  end

  subject(:notify_about_destroy_checkin) do
    described_class.call(device: device, checkin: checkin)
  end

  it "succeeds" do
    expect(notify_about_destroy_checkin.success?).to be_truthy
  end

  it "broadcasts destroy checkin message for friends" do
    notify_about_destroy_checkin
    expect(ActionCable.server).to have_received(:broadcast)
  end
end
