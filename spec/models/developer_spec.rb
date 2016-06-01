require 'rails_helper'

RSpec.describe Developer, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:developer) { FactoryGirl.create(:developer) }

  describe 'approvals' do
    it 'should ask for approval' do
      expect(developer.pending_approvals.count).to be 0
      expect(developer.users.count).to be 0

      Approval.link(user, developer, 'Developer')

      expect(developer.pending_approvals.count).to be 1
      expect(developer.users.count).to be 0

      Approval.accept(user, developer, 'Developer')

      expect(developer.pending_approvals.count).to be 0
      expect(developer.users.count).to be 1
    end
  end

  describe 'slack' do
    it 'should generate a helpful message for slack' do
      expect(developer.slack_message).to eq "A new developer registered, id: #{developer.id},"\
        " company_name: #{developer.company_name}, there are now #{Developer.count} developers."
    end
  end
end
