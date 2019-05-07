require "rails_helper"

RSpec.describe EmailRequest, type: :model do
  describe "factory" do
    it "creates a valid request" do
      req = build(:email_request)
      expect(req).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a user" do
      assc = described_class.reflect_on_association(:user)
      expect(assc.macro).to eq :belongs_to
    end
  end
end
