RSpec.describe Users::DevsApprovalsController, type: :controller do
  include ControllerMacros
  let(:user) { create_user }
  let(:developer) { FactoryGirl.create :developer }
  let(:approval) { FactoryGirl.create :approval, user: user }
  let(:approval_create_params) do
    { user_id: user.id, approval: { approvable: developer.company_name, approvable_type: 'Developer' } }
  end

  describe 'POST #create' do
    context 'when adding a developer' do
      it 'should create an accepted approval between user and developer' do
        post :create, approval_create_params
        expect(Approval.last.approvable_id).to eq developer.id
        expect(Approval.last.status).to eq 'accepted'
        expect(Approval.last.user).to eq user
      end

      it 'should confirm an existing developer approval request' do
        approval.update(status: 'developer-requested', approvable_id: developer.id, approvable_type: 'Developer')
        count = Approval.count
        post :create, approval_create_params
        expect(Approval.count).to eq count
        expect(Approval.last).to eq approval
        expect(Approval.last.status).to eq 'accepted'
      end
    end

    context 'when an incorrect name is provided' do
      it 'should not create an approval if Developer does not exist' do
        approval_create_params[:approval][:approvable] = 'does not exist'
        post :create, approval_create_params
        expect(Approval.count).to eq 0
        expect(flash[:alert]).to match 'not found'
      end

      it 'should not approve if trying to add an exisiting developer' do
        approval.update(status: 'accepted', approvable_id: developer.id, approvable_type: 'Developer')
        post :create, approval_create_params
        expect(flash[:alert]).to match 'exists'
        expect(Approval.count).to eq 1
      end
    end
  end
end
