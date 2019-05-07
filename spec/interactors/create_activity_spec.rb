require "rails_helper"

RSpec.describe CreateActivity, type: :interactor do
  subject(:create_context) do
    described_class.call(entity: device, action: :update, owner: user, params: { fogged: true })
  end

  let(:user) { create :user }
  let(:device) { create :device, user: user }

  describe "call" do
    it "succeeds" do
      expect(create_context).to be_a_success
    end

    it "creates a new activity" do
      expect { create_context }.to change { PublicActivity::Activity.count }.by 1
    end
  end
end
