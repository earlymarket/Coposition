require 'rails_helper'

RSpec.describe ApprovalsHelper, :type => :helper do
  describe '#approvals_input' do
    it 'should assign placeholder key a string' do
      expect(helper.approvals_input('Developer')[:placeholder]).to match 'name'
      expect(helper.approvals_input('User')[:placeholder]).to match 'Username'
    end

    it 'should assign class key' do
      expect(helper.approvals_input('User')[:class]).to match 'users'
      expect(helper.approvals_input('Developer')[:class]).to match 'devs'
    end
  end
end
