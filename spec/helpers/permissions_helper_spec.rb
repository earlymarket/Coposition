require "rails_helper"

RSpec.describe PermissionsHelper, type: :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:user) { create(:user) }
  let(:developer) { create(:developer) }
  let(:device) { create(:device, user_id: user.id) }
  let(:permission) do
    device.developers << developer
    Permission.last
  end

  describe "#permissions_permissible_title" do
    it "accepts either a user or a developer" do
      expect { helper.permissions_permissible_title(user, user) }.not_to raise_error
      expect { helper.permissions_permissible_title(user, developer) }.not_to raise_error
    end

    it "returns html with the user's shortened email or name if it's a user" do
      expect(helper.permissions_permissible_title(user, user)).to match(user.username)
      expect(helper.permissions_permissible_title(user, user).class).to eq(safebuffer)
    end

    it "returns html with the company name if it's a developer" do
      expect(helper.permissions_permissible_title(user, developer).class).to eq(safebuffer)
      expect(helper.permissions_permissible_title(user, developer)).to match(developer.company_name)
    end

    it "returns authenticated with the company name if it's a complete developer" do
      Approval.add_developer(user, developer).update(status: "complete")
      expect(helper.permissions_permissible_title(user, developer)).to match("authenticated")
    end
  end

  describe "#permissions_label_id" do
    it "returns the permissionable id and switch type if a Permission" do
      expect(helper.permissions_label_id(permission, "disallowed")).to include(permission.id.to_s)
      expect(helper.permissions_label_id(developer, "disallowed")).to include("master")
    end
  end

  describe "#permissions_switch_class" do
    it "returns a different string depending on whether permissible is a Permission or not" do
      expect(helper.permissions_switch_class(permission)).to include("permission")
      expect(helper.permissions_switch_class(developer)).to include("master")
    end
  end

  describe "#permissions_check_box_value" do
    it "returns a boolean value depending on if permissionable is a Permission depending on the type" do
      permission.update(privilege: "disallowed", bypass_delay: false, bypass_fogging: true)
      expect(helper.permissions_check_box_value(permission, "disallowed")).to eq true
      expect(helper.permissions_check_box_value(permission, "complete")).to eq false
      expect(helper.permissions_check_box_value(permission, "bypass_delay")).to eq false
      expect(helper.permissions_check_box_value(permission, "bypass_fogging")).to eq true
    end
  end

  describe "permissions_device_title" do
    it "returns a string" do
      expect(helper.permissions_device_title(device)).to be_kind_of String
    end

    it "returns a string containing device icon" do
      expect(helper.permissions_device_title(device)).to match device.icon
    end

    it "returns a string containing device name" do
      expect(helper.permissions_device_title(device)).to match device.name
    end
  end
end
