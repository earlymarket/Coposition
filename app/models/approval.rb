class Approval < ActiveRecord::Base

  belongs_to :user
  belongs_to :approvable, :polymorphic => true

  before_create do
    not_self = true
    if approvable_type == 'User'
      not_self = (user_id != approvable_id)
    end
    not_self && !Approval.exists?(user_id: user_id, approvable_id: approvable_id, approvable_type: approvable_type)
  end

  def self.link(user_id, approvable_id, approvable_type)
    if approvable_type == 'Developer'
      Approval.create(:user_id => user_id, :approvable_id => approvable_id, :approvable_type => approvable_type, :status => 'developer-requested' )
    else
      Approval.create(:user_id => user_id, :approvable_id => approvable_id, :approvable_type => approvable_type, :status => 'pending' )
      Approval.create(:user_id => approvable_id, :approvable_id => user_id, :approvable_type => approvable_type, :status => 'requested' )
    end
  end

  def self.accept(user_id, approvable_id, approvable_type)
    transaction do
      accept_one_side(user_id, approvable_id, approvable_type)
      accept_one_side(approvable_id, user_id, approvable_type) unless approvable_type == 'Developer'
    end
  end

  def self.accept_one_side(user_id, approvable_id, approvable_type)
    request = find_by_user_id_and_approvable_id_and_approvable_type(user_id, approvable_id, approvable_type)
    request.approve!
    request.save!
  end

  def approve!
    update(status: 'accepted')
    user.approve_devices(approvable)
  end

end