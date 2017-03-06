require "rails_helper"

RSpec.describe Permission, type: :model do
  let(:developer) { FactoryGirl.create(:developer) }
  let(:device) { FactoryGirl.create(:device) }
  let(:permission) { FactoryGirl.create(:permission, device: device, permissible: developer) }

  describe "factory" do
    it "creates a valid permission" do
      perm = FactoryGirl.build(:permission)
      expect(perm).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a developer" do
      assc = described_class.reflect_on_association(:developer)
      expect(assc.macro).to eq :belongs_to
    end

    it "belongs to a device" do
      assc = described_class.reflect_on_association(:device)
      expect(assc.macro).to eq :belongs_to
    end
  end
end
