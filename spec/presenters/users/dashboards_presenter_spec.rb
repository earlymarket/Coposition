require 'rails_helper'

describe ::Users::DashboardsPresenter do
  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user_id: user.id) }
  let(:checkins) { FactoryGirl.create(:checkin, device_id: device.id) }

  subject { ::Users::DashboardsPresenter.new(user) }

  describe 'Interface' do
    it { is_expected.to respond_to :most_frequent_areas }
    it { is_expected.to respond_to :percent_change }
    it { is_expected.to respond_to :weeks_checkins_count }
    it { is_expected.to respond_to :most_used_device }
    it { is_expected.to respond_to :last_countries }
    # it { is_expected.to respond_to :gon }
  end
end
