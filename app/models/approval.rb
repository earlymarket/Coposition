class Approval < ActiveRecord::Base

  belongs_to :user
  belongs_to :approvable, :polymorphic => true

  before_create do
    if approvable_type == 'User' && user == approvable
      errors.add(:base, "Adding self")
      false
    elsif Approval.exists?(user: user, approvable: approvable, approvable_type: approvable_type)
      errors.add(:base, "Approval/Request exists")
      false
    end
  end

  def self.construct(user, approvable, approvable_type)
    approval = Approval.link(user, approvable, approvable_type)
    if (approvable_type == 'Developer') || (user.friend_requests.include?(approvable))
      approval = Approval.accept(user, approvable, approvable_type)
    else
      UserMailer.add_friend_email(user, approvable).deliver_now
    end
    approval
  end

  def self.link(user, approvable, approvable_type)
    if approvable_type == 'Developer'
      Approval.create(user: user, approvable: approvable, approvable_type: approvable_type, status: 'developer-requested' )
    else
      Approval.create(user: user, approvable: approvable, approvable_type: approvable_type, status: 'pending' )
      Approval.create(user: approvable, approvable: user, approvable_type: approvable_type, status: 'requested' )
    end
  end

  def self.accept(user, approvable, approvable_type)
    accept_one_side(approvable, user, approvable_type) unless approvable_type == 'Developer'
    accept_one_side(user, approvable, approvable_type)
  end

  def self.accept_one_side(user, approvable, approvable_type)
    approval = find_by_user_id_and_approvable_id_and_approvable_type(user.id, approvable.id, approvable_type)
    approval.approve!
    approval
  end

  def approve!
    update(status: 'accepted', approval_date: Time.now)
    user.approve_devices(approvable)
  end

end

