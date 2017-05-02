require "rails_helper"

RSpec.describe Permission, type: :model do
  describe "factory" do
    it "creates a valid permission" do
      perm = build(:permission)
      expect(perm).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a user or developer" do
      assc = described_class.reflect_on_association(:permissible)
      expect(assc.macro).to eq :belongs_to
    end

    it "belongs to a device" do
      assc = described_class.reflect_on_association(:device)
      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "Callbacks" do
    it "changes privilege level before create" do
      new_permission = build(:permission)
      expect { new_permission.save }.to change { new_permission.privilege }
    end
  end

  describe "public class methods" do
    context "responds to its method" do
      it { expect(Permission).to respond_to(:not_coposition_developers) }
    end

    context "not_coposition_developers" do
      it "returns a collection of permissions" do
        expect(Permission.not_coposition_developers).to be_kind_of(ActiveRecord::Relation)
      end

      it "returns a permission not belonging to a copo developer" do
        dev = Developer.default(coposition: true)
        device = create(:device)
        perm = create(:permission, device: device, permissible: dev)
        expect(Permission.not_coposition_developers).not_to include perm
      end
    end
  end
end
