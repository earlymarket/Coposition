require "rails_helper"

RSpec.describe Request, type: :model do
  let(:developer) { create(:developer) }
  let(:request) { create :request, developer: developer }

  describe "factory" do
    it "creates a valid request" do
      req = build(:request)
      expect(req).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a developer" do
      assc = described_class.reflect_on_association(:developer)
      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "Scopes" do
    before do
      request
      create(:request, developer: developer, created_at: 1.day.ago)
    end

    it "returns requests ordered by created at descending by default" do
      expect(Request.first).to eq request
    end

    context "since" do
      it "returns requests since a certain time" do
        expect(Request.since(1.hour.ago)).to eq [request]
      end
    end
  end
end
