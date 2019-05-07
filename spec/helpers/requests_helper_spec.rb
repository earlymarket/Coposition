require 'rails_helper'

RSpec.describe RequestsHelper, type: :helper do
  let(:user) { create(:user) }
  let(:developer) { create(:developer) }
  let(:request_user) { create(:request, developer: developer, user_id: user.id) }
  let(:request) { create(:request, developer: developer) }

  describe '#requests_user' do
    it 'should return the users username if the request has a user' do
      expect(helper.requests_user(request_user)).to eq user.username
    end

    it 'should return nil if request has no user' do
      expect(helper.requests_user(request)).to eq 'n/a'
    end
  end
end
