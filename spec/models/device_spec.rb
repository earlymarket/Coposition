require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:developer) { create :developer }
  let(:device) do
    dev = create(:device)
    dev.developers << developer
    dev
  end
  let(:checkin) { create :checkin, device: device }

  describe 'relationships' do
    it 'has some checkins' do
      expect(device.checkins).to match_array([checkin])
    end

    it 'has some approved developers' do
      expect(device.developers.first).to eq developer
    end
  end

  it 'gets the privilege level for a developer' do
    expect(device.permission_for(developer).privilege).to eq 'last_only'
  end

  describe 'slack' do
    it 'generates a helpful message for slack' do
      expect(device.slack_message).to eq "A new device was created, id: #{device.id},"\
        " name: #{device.name}, user_id: #{device.user_id}. There are now #{Device.count} devices"
    end
  end

  describe "#broadcast_methods" do
    let(:user) { device.user }
    let(:friend) { create :user }
    let(:checkin_message) { { action: "checkin", privilege: "last_only", msg: checkin.as_json }}
    let(:destroy_checkin_message) { { action: "destroy", msg: checkin.as_json }}

    before do
      Approval.add_friend(user, friend)
      Approval.add_friend(friend, user)
    end

    context "checkin" do
      it "broadcasts checkin message for friends" do
        expect(ActionCable.server)
          .to receive(:broadcast)
          .with "friends_#{friend.id}", checkin_message

        device.broadcast_checkin_for_friends(checkin)
      end
    end

    context "destroy" do
      it "broadcasts destroy checkin message for friends" do
        expect(ActionCable.server)
          .to receive(:broadcast)
          .with "friends_#{friend.id}", destroy_checkin_message

        device.broadcast_destroy_checkin_for_friends(checkin)
      end
    end
  end

  describe "#can_bypass_fogging?" do
    let(:permission) { double "permission", bypass_fogging: bypass_fogging }
    let(:permissions) { double "permissions" }
    let(:permissible) { create :user }

    subject(:can_bypass_fogging) { device.can_bypass_fogging?(permissible) }

    before do
      allow(device)
        .to receive(:permissions)
        .and_return(permissions)
      allow(permissions)
        .to receive(:find_by)
        .with(permissible_id: permissible.id, permissible_type: permissible.class.to_s)
        .and_return(permission)
    end

    context "when permission has bypass_fogging" do
      let(:bypass_fogging) { true }

      it "returns true" do
        expect(can_bypass_fogging).to be_truthy
      end
    end

    context "when permission has no bypass_fogging" do
      let(:bypass_fogging) { false }

      it "returns false" do
        expect(can_bypass_fogging).to be_falsy
      end
    end
  end

  describe "#can_bypass_delay?" do
    let(:permission) { double "permission", bypass_delay: bypass_delay }
    let(:permissions) { double "permissions" }
    let(:permissible) { create :user }

    subject(:can_bypass_delay) { device.can_bypass_delay?(permissible) }

    before do
      allow(device)
        .to receive(:permissions)
        .and_return(permissions)
      allow(permissions)
        .to receive(:find_by)
        .with(permissible_id: permissible.id, permissible_type: permissible.class.to_s)
        .and_return(permission)
    end

    context "when permission has bypass_delay" do
      let(:bypass_delay) { true }

      it "returns true" do
        expect(can_bypass_delay).to be_truthy
      end
    end

    context "when permission has no bypass_delay" do
      let(:bypass_delay) { false }

      it "returns false" do
        expect(can_bypass_delay).to be_falsy
      end
    end
  end

  describe "#slack_message" do
    subject(:message) { device.slack_message }

    it "includes id, name and user_id" do
      expect(message).to match("#{device.id}")
      expect(message).to match("#{device.name}")
      expect(message).to match("#{device.user_id}")
    end
  end
end
