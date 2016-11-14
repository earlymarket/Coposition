require 'rails_helper'

RSpec.describe Users::DashboardsController, type: :controller do
  include ControllerMacros
  let(:checkin) { FactoryGirl.create(:checkin) }
  let(:device) do
    dev = FactoryGirl.create :device
    dev.checkins << [checkin, FactoryGirl.create(:checkin, created_at: 10.days.ago)]
    dev
  end
  let(:user) do
    user = create_user
    user.devices << device
    user
  end
  let(:second_user) { FactoryGirl.create :user }


  describe 'GET #show' do
    it 'should load metadata for dashboard page' do
      get :show, params: { user_id: user.id }
      expect((assigns :presenter).class).to eq(Users::DashboardsPresenter)
      expect((assigns :presenter).most_used_device).to eq device
    end

    it 'should redirect to correct url if wrong user_id provided' do
      user
      get :show, params: { user_id: second_user.id }
      expect(response).to redirect_to(controller: 'users/dashboards', action:'show', user_id: user.friendly_id)
    end
  end
end
