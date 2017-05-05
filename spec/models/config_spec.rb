require "rails_helper"

RSpec.describe Config, type: :model do
  describe "factory" do
    it "creates a valid config" do
      conf = build(:config)
      expect(conf).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a device" do
      assc = described_class.reflect_on_association(:device)
      expect(assc.macro).to eq :belongs_to
    end

    it "belongs to a developer" do
      assc = described_class.reflect_on_association(:developer)
      expect(assc.macro).to eq :belongs_to
    end
  end
end
