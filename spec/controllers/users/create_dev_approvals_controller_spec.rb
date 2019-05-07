require 'rails_helper'

RSpec.describe Users::CreateDevApprovalsController, type: :controller do
  include ControllerMacros
  let(:user) { create_user }
  let(:developer) { create :developer }
  let(:approval) { create :approval, user: user }
  let(:approval_create_params) do
    { user_id: user.id, approval: { approvable: developer.company_name, approvable_type: 'Developer' } }
  end

  describe 'POST #create' do
    context 'when adding a developer' do
      it 'should create an accepted approval between user and developer' do
        post :create, params: approval_create_params
        expect(Approval.where(user: user, approvable: developer, status: 'accepted')).to exist
      end

      it 'should confirm an existing developer approval request' do
        approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
        count = Approval.count
        post :create, params: approval_create_params
        expect(Approval.count).to eq count
        expect(Approval.where(user: user, approvable: developer, status: 'accepted')).to exist
      end

      it 'should not create an approval if Developer does not exist' do
        approval_create_params[:approval][:approvable] = 'does not exist'
        approval_count = Approval.count
        post :create, params: approval_create_params
        expect(Approval.count).to eq approval_count
        expect(flash[:alert]).to match 'not found'
      end

      it 'should not approve if trying to add an already approved developer' do
        approval.update(status: 'accepted', approvable_id: developer.id, approvable_type: 'Developer')
        approval_count = Approval.count
        post :create, params: approval_create_params
        expect(flash[:alert]).to match 'already connected'
        expect(Approval.count).to eq approval_count
      end
    end
  end
end
