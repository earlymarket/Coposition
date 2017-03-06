require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:developer) { FactoryGirl.create :developer }
  let(:device) do
    dev = FactoryGirl.create(:device, user: user)
    Approval.link(user, developer, "Developer")
    Approval.accept(user, developer, "Developer")
    dev.developers << developer
    dev
  end
  let(:checkins) do
    device.checkins << FactoryGirl.create(:checkin)
  end
  let(:user) { FactoryGirl.create(:user) }

  describe "factory" do
    it "creates a valid device" do
      expect(device).to be_valid
    end

    it "is invalid without a unique username" do
      FactoryGirl.create(:device, name: "laptop", user: user)
      expect(FactoryGirl.build(:device, name: "laptop", user: user)).not_to be_valid
    end
  end

  describe "Associations" do
    it "belongs to user" do
      assc = described_class.reflect_on_association(:user)
      expect(assc.macro).to eq :belongs_to
    end

    %w(config configurer).each do |asoc|
      it "has many #{asoc}" do
        assc = described_class.reflect_on_association(asoc.to_sym)
        expect(assc.macro).to eq :has_one
      end
    end

    %w(checkins developers permissions permitted_users).each do |asoc|
      it "has many #{asoc}" do
        assc = described_class.reflect_on_association(asoc.to_sym)
        expect(assc.macro).to eq :has_many
      end
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      %i(construct safe_checkin_info_for filtered_checkins sanitize_checkins replace_checkin_attributes
         permitted_history_for resolve_privilege privilege_for delayed_checkins_for permission_for
         can_bypass_fogging? can_bypass_delay? slack_message update_delay switch_fog humanize_delay
         public_info subscriptions notify_subscribers).each do |method|
        it { expect(device).to respond_to(method) }
      end
    end

    context "construct" do
      let(:new_device) { FactoryGirl.build(:device) }

      it "returns true if successful update" do
        expect(new_device.construct(user, "laptop", "laptop")).to be true
      end

      it "returns nil if username taken by another device belonging to current user" do
        expect(new_device.construct(user, device.name, "laptop")).to be nil
      end
    end

    context "safe_checkin_info_for" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "calls sanitize_checkins" do
        allow(device).to receive(:sanitize_checkins)
        device.safe_checkin_info_for(permissible: developer)
        expect(device).to have_received(:sanitize_checkins)
      end

      it "returns an association relation" do
        expect(device.safe_checkin_info_for(permissible: developer)).to be_kind_of(ActiveRecord::AssociationRelation)
      end
    end

    context "filtered_checkins" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "returns an association relation" do
        expect(device.filtered_checkins(permissible: developer)).to be_kind_of(ActiveRecord::AssociationRelation)
      end
    end

    context "sanitize_checkins" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "returns an association relation" do
        result = device.sanitize_checkins(device.checkins, permissible: developer)
        expect(result).to be_kind_of(ActiveRecord::AssociationRelation)
      end
    end

    context "replace_checkin_attributes" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "returns an association relation" do
        result = device.replace_checkin_attributes(device.checkins, developer)
        expect(result).to be_kind_of(ActiveRecord::AssociationRelation)
      end

      it "removes certain attributes" do
        result = device.replace_checkin_attributes(device.checkins, developer)[0]
        expect(result).not_to respond_to(:fogged_lat, :fogged_lng, :fogged_city)
      end
    end

    context "permitted_history_for" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "calls resolve_privilege" do
        allow(device).to receive(:resolve_privilege)
        device.permitted_history_for(developer)
        expect(device).to have_received(:resolve_privilege)
      end

      it "returns an association relation" do
        expect(device.permitted_history_for(developer)).to be_kind_of(ActiveRecord::AssociationRelation)
      end

      it "returns no checkins if device cloaked" do
        device.update(cloaked: true)
        expect(device.permitted_history_for(developer)).to eq Checkin.none
      end
    end

    context "resolve_privilege" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "returns an association relation" do
        result = device.resolve_privilege(device.checkins, developer)
        expect(result).to be_kind_of(ActiveRecord::AssociationRelation)
      end
    end

    context "privilege_for" do
      it "returns the privilege level" do
        privilege = device.permission_for(developer).privilege
        expect(device.privilege_for(developer)).to eq privilege
      end
    end

    context "delayed_checkins_for" do
      before do
        FactoryGirl.create(:checkin, device: device)
      end

      it "returns an association relation" do
        expect(device.delayed_checkins_for(developer)).to be_kind_of(ActiveRecord::AssociationRelation)
      end
    end

    context "permission_for" do
      it "returns a permission" do
        expect(device.permission_for(developer)).to be_kind_of Permission
      end
    end

    context "can_bypass_fogging?" do
      it "returns true if developer can bypass fogging" do
        device.permission_for(developer).update(bypass_fogging: true)
        device.permission_for(developer).update(bypass_fogging: true)
        expect(device.can_bypass_fogging?(developer)).to be true
      end
      it "returns false if developer can't bypass fogging" do
        expect(device.can_bypass_fogging?(developer)).to be false
      end
    end

    context "can_bypass_delay?" do
      it "returns true if developer can bypass delay" do
        device.permission_for(developer).update(bypass_delay: true)
        device.permission_for(developer).update(bypass_delay: true)
        expect(device.can_bypass_delay?(developer)).to be true
      end
      it "returns false if developer can't bypass delay" do
        expect(device.can_bypass_delay?(developer)).to be false
      end
    end

    context "slack_message" do
      it "return slack message string" do
        msg = "A new device was created, id: #{device.id}, name: #{device.name}, user_id: #{device.user_id}. "\
              "There are now #{Device.count} devices"
        expect(device.slack_message).to eq msg
      end
    end

    context "update_delay" do
      it "updates device delay to given number" do
        device.update_delay 60
        expect(device.delayed).to eq 60
      end

      it "updates device delay to nil if zero given" do
        device.update_delay 0
        expect(device.delayed).to eq nil
      end
    end

    context "switch_fog" do
      it "switches device fog" do
        device.switch_fog
        expect(device.fogged).to eq false
      end

      it "returns fogged status" do
        expect(device.switch_fog).to eq false
      end
    end

    context "humanize_delay" do
      it "returns a string explaining delay setting" do
        device.update(delayed: 10)
        string = "#{device.name} delayed by 10 minutes."
        expect(device.humanize_delay).to eq string
      end

      it "returns a different string if device not delayed" do
        string = "#{device.name} is not delayed."
        expect(device.humanize_delay).to eq string
      end
    end

    context "public_info" do
      it "returns a Device" do
        expect(device.public_info).to be_kind_of(Device)
      end

      it "returns devices public info" do
        expect(device.public_info).not_to respond_to(:uuid)
      end
    end

    context "subscriptions" do
      it "returns subscriptions to a certain event" do
        subscrp = FactoryGirl.create(:subscription, subscriber: user)
        expect(device.subscriptions("new_checkin")).to eq [subscrp]
      end
    end

    context "notify_subscribers" do
      it "does nothing if user not zapier enabled" do
        expect(device.notify_subscribers("new_checkin", checkins.last)).to eq nil
      end

      it "does nothing if no subscriptions" do
        user.update(zapier_enabled: true)
        expect(device.notify_subscribers("new_checkin", checkins.last)).to eq nil
      end

      it "calls remove_id if zapier_enabled and subscriptions" do
        user.update(zapier_enabled: true)
        FactoryGirl.create(:subscription, subscriber: user)
        allow(device).to receive(:remove_id).and_return(device)
        device.notify_subscribers("new_checkin", checkins.last)
        expect(device).to have_received(:remove_id)
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(public_info last_checkins geocode_last_checkins ordered_by_checkins).each do |method|
        it { expect(Device).to respond_to(method) }
      end
    end

    context "public_info" do
      it "returns all devices public info" do
        expect(Device.public_info).to eq(Device.select(%i(id user_id name alias published)))
      end
    end

    context "last_checkins" do
      before do
        checkins
      end

      it "returns an array" do
        expect(Device.last_checkins).to be_kind_of(Array)
      end

      it "returns each devices first checkin" do
        expect(Device.last_checkins[0]).to eq checkins.last
      end
    end

    context "geocode_last_checkins" do
      before do
        checkins
      end

      it "returns an array" do
        expect(Device.geocode_last_checkins).to be_kind_of(Array)
      end

      it "geocodes each devices most recent checkin" do
        Device.geocode_last_checkins
        expect(device.checkins.first.reverse_geocoded?).to eq true
      end
    end

    context "ordered_by_checkins" do
      it "returns devices in order of most recent checkin created" do
        checkins
        new_device = FactoryGirl.create(:device, user: user)
        FactoryGirl.create(:checkin, device: new_device, created_at: 1.day.ago)
        expect(Device.ordered_by_checkins).to eq [device, new_device]
      end
    end
  end
end
