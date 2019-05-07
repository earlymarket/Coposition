require "rails_helper"

describe ::ActivitiesPresenter do
  subject(:activities) { described_class.new(params) }
  let(:params) { {} }
  let(:user) { create(:user) }
  let(:second_user) { create(:user) }
  let(:device) { create(:device) }
  let(:second_device) { create(:device) }
  let!(:activity) { create(:activity, owner_id: user.id, trackable_type: "Approval") }
  let!(:second_activity) do
    create(:activity, owner_id: second_user.id, trackable_type: "Device", trackable_id: device.id)
  end

  describe "Interface" do
    %i(activities gon).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "activities" do
    it "returns a relation of activities" do
      expect(activities.activities).to eq [second_activity, activity]
    end

    it "returns activities belonging to specified user" do
      activities = described_class.new(owner_id: user.email, search: true)
      expect(activities.activities).to eq [activity]
    end

    it "returns activities belonging to specified trackable type" do
      activities = described_class.new("Device" => "true", search: true)
      expect(activities.activities).to eq [second_activity]
    end

    it "returns activities belonging to specified trackable" do
      activities = described_class.new(ActionController::Parameters.new(filter: true, trackable_type: "Device",
                                                                        trackable_id: device.id))
      expect(activities.activities).to eq [second_activity]
    end
  end

  describe "gon" do
    it "returns a hash" do
      expect(activities.gon).to be_kind_of Hash
    end

    it "returns a hash containing all users emails" do
      expect(activities.gon[:users]).to eq User.pluck(:email)
    end
  end
end
