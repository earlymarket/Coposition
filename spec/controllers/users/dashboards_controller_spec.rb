require 'rails_helper'

RSpec.describe Users::DashboardsController, type: :controller do
  include ControllerMacros
  let(:checkin) { FactoryGirl::create(:checkin) }
  let(:device) do
    dev = FactoryGirl::create :device
    dev.checkins << [checkin, FactoryGirl::create(:checkin, created_at: 10.days.ago)]
    dev
  end
  let(:user) do
    user = create_user
    user.devices << device
    user
  end

  describe 'GET #show' do
    it 'should load metadata for dashboard page' do
      get :show, user_id: user.id
      expect((assigns :presenter).class).to eq(Users::DashboardsPresenter)
      expect((assigns :presenter).most_used_device).to eq device
    end
  end
end
