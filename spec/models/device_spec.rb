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

    end

    context "can_bypass_fogging?" do

    end

    context "can_bypass_delay?" do

    end

    context "slack_message" do

    end

    context "update_delay" do

    end

    context "switch_fog" do

    end

    context "humanize_delay" do

    end

    context "public_info" do
    end

    context "subscriptions" do
    end

    context "notify_subscribers" do
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      # it { expect(user).to respond_to(:public_info) }
    end

    context "" do

    end
  end
end
