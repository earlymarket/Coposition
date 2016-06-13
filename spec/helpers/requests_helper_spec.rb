require 'rails_helper'

RSpec.describe RequestsHelper, type: :helper do
  let(:user) { FactoryGirl.create(:user) }
  let(:developer) { FactoryGirl.create(:developer) }
  let(:request_user) { FactoryGirl.create(:request, developer: developer, user_id: user.id) }
  let(:request) { FactoryGirl.create(:request, developer: developer) }

  describe '#requests_user' do
    it 'should return the users username if the request has a user' do
      expect(helper.requests_user(request_user)).to eq user.username
    end

    it 'should return nil if request has no user' do
      expect(helper.requests_user(request)).to eq nil
    end
  end
end
