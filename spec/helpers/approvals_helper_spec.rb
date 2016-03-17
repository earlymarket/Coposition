require 'rails_helper'

RSpec.describe ApprovalsHelper, :type => :helper do
  let(:user) do
    user = FactoryGirl::create(:user)
    user.pending_friends << [FactoryGirl::create(:user), FactoryGirl::create(:user)]
    user
 end

  describe '#approvals_input' do
    it 'should assign placeholder key a string' do
      expect(helper.approvals_input('Developer')[:placeholder]).to match 'name'
      expect(helper.approvals_input('User')[:placeholder]).to match 'email@email.com'
    end

    it 'should assign class key' do
      expect(helper.approvals_input('User')[:class]).to match 'validate'
      expect(helper.approvals_input('Developer')[:class]).to match 'devs'
    end
  end

  describe '#approvals_pending_friends' do
    it 'should return a string with emails of users who requests sent to' do
      expect(helper.approvals_pending_friends(user)).to be_kind_of(String)
      expect(helper.approvals_pending_friends(user)).to_not match ','
      expect(helper.approvals_pending_friends(user)).to match 'and'
      user.pending_friends << FactoryGirl::create(:user)
      expect(helper.approvals_pending_friends(user)).to match ','
    end
  end
end
