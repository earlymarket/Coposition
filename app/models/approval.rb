class Approval < ActiveRecord::Base

  belongs_to :user
  belongs_to :approvable, :polymorphic => true

  before_create do
    bool = true
    if approvable_type == 'User'
      bool = (user_id != approvable_id)
    end
    bool && !Approval.exists?(user_id: user_id, approvable_id: approvable_id, approvable_type: approvable_type)
  end

  def self.link(user_id, approvable_id, approvable_type)
    Approval.create(:user_id => user_id, :approvable_id => approvable_id, :approvable_type => approvable_type, :status => 'pending' )
    Approval.create(:user_id => approvable_id, :approvable_id => user_id, :approvable_type => approvable_type, :status => 'requested' ) unless approvable_type == 'Developer'
  end

  def self.accept(user_id, approvable_id, approvable_type)
    transaction do
      accept_one_side(user_id, approvable_id)
      accept_one_side(approvable_id, user_id) unless approvable_type == 'Developer'
    end
  end

  def self.accept_one_side(user_id, approvable_id)
    request = find_by_user_id_and_approvable_id(user_id, approvable_id)
    request.status = 'accepted'
    request.save!
  end

  def approve!
    update(status: 'accepted')
    user.approve_devices_for_developer(Developer.find(approvable_id))
  end

  def reject!
    update(status: 'rejected')
  end

end