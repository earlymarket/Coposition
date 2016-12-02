require 'rails_helper'

describe ::Users::DashboardsPresenter do
  let(:user) { FactoryGirl.create(:user) }
  let(:device) { FactoryGirl.create(:device, user_id: user.id) }
  let(:checkins) do
    FactoryGirl.create(:checkin, device_id: device.id)
    FactoryGirl.create(:checkin, device_id: device.id).reverse_geocode!
    FactoryGirl.create(:checkin, device_id: device.id)
  end

  subject do
    checkins
    ::Users::DashboardsPresenter.new(user)
  end

  describe 'Interface' do
    it { is_expected.to respond_to :most_frequent_areas }
    it { is_expected.to respond_to :percent_change }
    it { is_expected.to respond_to :weeks_checkins_count }
    it { is_expected.to respond_to :most_used_device }
    it { is_expected.to respond_to :last_countries }
    it { is_expected.to respond_to :gon }
  end

  describe 'last_countries' do
    it 'should return checkins by unique country_code in the order visited' do
      last_countries = subject.last_countries
      expect(last_countries.length).to eq 2
      expect(last_countries[0]).to eq device.checkins.first
      expect(last_countries[1].city).to eq 'Denham'
    end
  end
end
