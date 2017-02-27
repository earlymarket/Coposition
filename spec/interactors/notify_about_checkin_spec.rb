require "rails_helper"

describe NotifyAboutCheckin do
  let(:device) { create :device }
  let(:checkin) { create :checkin, device: device }

  subject(:notify_about_checkin) do
    described_class.call(device: device, checkin: checkin)
  end

  before do
    allow(device)
      .to receive(:notify_subscribers)
    allow(device)
      .to receive(:broadcast_checkin_for_friends)
  end

  it "notifies device subscribers" do
    expect(notify_about_checkin.success?).to be_truthy

    
    expect(device)
      .to have_received(:notify_subscribers).with("new_checkin", checkin)
  end

  it "does broadcasting for friends" do
    expect(notify_about_checkin.success?).to be_truthy

    expect(device)
      .to have_received(:broadcast_checkin_for_friends).with(checkin)
  end
end
