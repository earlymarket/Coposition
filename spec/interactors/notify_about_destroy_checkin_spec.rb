require "rails_helper"

describe NotifyAboutDestroyCheckin do
  let(:device) { create :device }
  let(:checkin) { create :checkin, device: device }

  subject(:notify_about_checkin) do
    described_class.call(device: device, checkin: checkin)
  end

  before do
    allow(device)
      .to receive(:broadcast_destroy_checkin_for_friends)
  end

  it "does broadcasting destroy checkin for friends" do
    expect(notify_about_checkin.success?).to be_truthy

    expect(device)
      .to have_received(:broadcast_destroy_checkin_for_friends).with(checkin)
  end
end
