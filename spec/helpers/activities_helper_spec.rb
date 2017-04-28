require "rails_helper"

RSpec.describe ActivitiesHelper, type: :helper do
  let(:device) { FactoryGirl.create(:device) }
  let!(:activity) { FactoryGirl.create(:activity, trackable_id: device.id) }

  describe "link_to_activity" do
    it "returns a link if activity trackable exists" do
      expect(helper.link_to_activity(activity)).to match "/activities?"
    end

    it "returns a trackable type if trackable no longer exists" do
      activity = FactoryGirl.create :activity
      expect(helper.link_to_activity(activity)).to match activity.trackable_type
    end
  end
end
