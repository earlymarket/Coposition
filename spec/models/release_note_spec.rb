require "rails_helper"

RSpec.describe ReleaseNote, type: :model do
  let!(:release_note) { create :release_note }

  describe "factory" do
    it "creates a valid request" do
      expect(release_note).to be_valid
    end
  end

  describe "Scopes" do
    it "returns requests ordered by created at descending by default" do
      create :release_note
      expect(ReleaseNote.first.created_at).to be > ReleaseNote.last.created_at
    end
  end
end
