require "rails_helper"

describe ::Users::PermissionsPresenter do
  subject(:permissions) do
    described_class.new(user, { id: permission.id, device_id: device.id, from: "devices" }, "index" )
  end
  let(:user) do
    us = FactoryBot.create(:user)
    Approval.add_friend(us, friend)
    Approval.add_friend(friend, us)
    Approval.add_developer(us, developer)
    us
  end
  let(:permission) { device.permissions.last }
  let(:developer) { create(:developer) }
  let(:friend) { create(:user) }
  let(:device) do
    device = create(:device, user_id: user.id)
    device.permitted_users << friend
    device
  end
  let(:checkins) do
    create(:checkin, device_id: device.id)
    create(:checkin, device_id: device.id).reverse_geocode!
    create(:checkin, device_id: device.id)
  end

  describe "Interface" do
    %i(permissible device permissions permission devices_index
       approvals_index update gon devices_gon apps_gon friends_gon).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "permissible" do
    it "returns a User if from friends page" do
      permissions = described_class.new(user, { id: permission.id, device_id: friend.id, from: "friends" }, "index" )
      expect(permissions.permissible).to eq friend
    end

    it "returns a Developer if from apps page" do
      permissions = described_class.new(user, { id: permission.id, device_id: developer.id, from: "apps" }, "index" )
      expect(permissions.permissible).to eq developer
    end
  end

  describe "device" do
    it "returns a device" do
      expect(permissions.device).to eq device
    end
  end

  describe "permissions" do
    it "returns array of permissions" do
      expect(permissions.permissions[0]).to be_kind_of Permission
    end
  end

  describe "permission" do
    it "returns a permission" do
      permissions = described_class.new(user, { id: permission.id, device_id: friend.id, from: "friends" }, "update" )
      expect(permissions.permission).to eq permission
    end
  end

  describe "devices_index" do
    it "calls not_coposition_developers" do
      allow(Permission).to receive(:not_coposition_developers).and_return device.permissions
      permissions.devices_index
      expect(Permission).to have_received(:not_coposition_developers).twice
    end
  end

  describe "approvals_index" do
    context "with from param friends" do
      it "returns permissions for friends only" do
        permissions = described_class.new(user, { device_id: friend.id, from: "friends" }, "index" )
        all_friends = permissions.approvals_index("friends").all? { |permission| permission.permissible_type == "User" }
        expect(all_friends).to eq true
      end
    end

    context "with from param apps" do
      it "returns permissions for apps only" do
        permissions = described_class.new(user, { device_id: developer.id, from: "apps" }, "index" )
        all_apps = permissions.approvals_index("apps").all? { |permission| permission.permissible_type == "Developer" }
        expect(all_apps).to eq true
      end
    end
  end

  describe "update" do
    it "returns a permission" do
      expect(permissions.update).to be_kind_of Permission
    end
  end

  describe "gon" do
    it "calls devices_gon with from devices" do
      allow(permissions).to receive(:devices_gon)
      permissions.gon("devices")
      expect(permissions).to have_received(:devices_gon)
    end

    it "calls apps_gon with from apps" do
      allow(permissions).to receive(:apps_gon)
      permissions.gon("apps")
      expect(permissions).to have_received(:apps_gon)
    end

    it "calls friends_gon with from friends" do
      allow(permissions).to receive(:friends_gon)
      permissions.gon("friends")
      expect(permissions).to have_received(:friends_gon)
    end
  end

  describe "devices_gon" do
    it "returns a hash" do
      expect(permissions.devices_gon).to be_kind_of Hash
    end

    it "calls devices_index_checkins" do
      allow(permissions).to receive(:devices_index_checkins)
      permissions.devices_gon
      expect(permissions).to have_received(:devices_index_checkins)
    end
  end

  describe "apps_gon" do
    it "returns a hash" do
      expect(permissions.apps_gon).to be_kind_of Hash
    end

    it "calls approvals_permissions with developer argument" do
      allow(permissions).to receive(:approvals_permissions).with("Developer")
      permissions.apps_gon
      expect(permissions).to have_received(:approvals_permissions)
    end

    it "calls Developer.public_info" do
      allow(Developer).to receive(:public_info)
      permissions.apps_gon
      expect(Developer).to have_received(:public_info)
    end
  end

  describe "friends_gon" do
    it "returns a hash" do
      expect(permissions.friends_gon).to be_kind_of Hash
    end

    it "calls approvals_permissions with user argument" do
      allow(permissions).to receive(:approvals_permissions).with("User")
      permissions.friends_gon
      expect(permissions).to have_received(:approvals_permissions)
    end

    it "calls User.public_info" do
      allow(User).to receive(:public_info)
      permissions.friends_gon
      expect(User).to have_received(:public_info)
    end
  end

  describe "devices_index_checkins" do
    it "returns an empty array if checkins not present" do
      expect(permissions.send(:devices_index_checkins)).to eq []
    end

    context "with checkins" do
      before do
        checkins
      end

      it "returns an array" do
        expect(permissions.send(:devices_index_checkins)).to be_kind_of Array
      end

      it "returns only one checkin per device" do
        create(:device, user: user)
        create(:checkin, device: Device.last)
        devices_count = Device.joins(:checkins).distinct.all.count
        expect(permissions.send(:devices_index_checkins).length).to eq devices_count
      end
    end
  end

  describe "approvals_permissions" do
    it "returns an ActiveRecord::AssociationRelation" do
      expect(permissions.send(:approvals_permissions, "Developer")).to be_kind_of ActiveRecord::AssociationRelation
    end

    it "calls Permission.not_coposition_developers" do
      allow(Permission).to receive(:not_coposition_developers).and_return device.permissions
      permissions.send(:approvals_permissions, "Developer")
      expect(Permission).to have_received(:not_coposition_developers).twice
    end

    context "with Developer argument" do
      it "returns permissions for Developers only" do
        perms = permissions.send(:approvals_permissions, "Developer")
        expect(perms.all? { |permission| permission.permissible_type == "Developer" }).to eq true
      end
    end

    context "with User argument" do
      it "returns permissions for Developers only" do
        perms = permissions.send(:approvals_permissions, "User")
        expect(perms.all? { |permission| permission.permissible_type == "User" }).to eq true
      end
    end
  end
end
