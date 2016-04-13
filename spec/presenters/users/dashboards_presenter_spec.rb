require 'rails_helper'

describe ::Users::DashboardsPresenter do

  let(:checkins) do
    FactoryGirl::create(:checkin)
    Checkin.all
  end

  subject { ::Users::DashboardsPresenter.new(checkins) }

  describe 'Interface' do
    it { is_expected.to respond_to :most_frequent_areas }
    it { is_expected.to respond_to :percent_change }
    it { is_expected.to respond_to :weeks_checkins_count }
    it { is_expected.to respond_to :weeks_checkins }
    it { is_expected.to respond_to :most_used_device }

    # This bit is probably overkill but I wanted to show that it works

    it { is_expected.to_not respond_to :checkins }
    it { is_expected.to_not respond_to :fogged_area_count }
    it { is_expected.to_not respond_to :device_checkins_count }
  end

  describe 'Output' do
    # expect(assigns :most_used_device).to eq(device)
    # expect(assigns :week_checkins_count).to eq(Checkin.count)
    # expect((assigns :most_frequent_areas).class).to eq(Array)
  end

end
