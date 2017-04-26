class Approval < ApplicationRecord
  include PublicActivity::Common
  belongs_to :user
  belongs_to :approvable, polymorphic: true

  before_create do
    if approvable_type == "User" && user == approvable
      errors.add(:base, "Adding self")
      throw(:abort)
    elsif Approval.exists?(user: user, approvable: approvable, approvable_type: approvable_type)
      errors.add(:base, "Approval/Request exists")
      throw(:abort)
    end
  end

  def self.add_developer(user, developer)
    approval = Approval.link(user, developer, "Developer")
    if user.request_from?(developer) || approval.errors.empty?
      approval = Approval.accept(user, developer, "Developer")
    end
    approval
  end

  def self.add_friend(user, friend)
    approval = Approval.link(user, friend, "User")
    if user.request_from?(friend)
      approval = Approval.accept(user, friend, "User")
    else
      UserMailer.add_user_email(user, friend, false).deliver_now unless approval.errors.messages.present?
    end
    approval
  end

  def self.link(user, approvable, approvable_type)
    if approvable_type == "Developer"
      Approval.create(user: user, approvable: approvable,
                      approvable_type: approvable_type, status: "developer-requested")
    else
      Approval.create(user: user, approvable: approvable,
                      approvable_type: approvable_type, status: "pending")
      Approval.create(user: approvable, approvable: user,
                      approvable_type: approvable_type, status: "requested")
    end
  end

  def self.accept(user, approvable, approvable_type)
    accept_one_side(approvable, user, approvable_type) unless approvable_type == "Developer"
    accept_one_side(user, approvable, approvable_type)
  end

  def self.accept_one_side(user, approvable, approvable_type)
    approval = find_by(user_id: user.id, approvable_id: approvable.id, approvable_type: approvable_type)
    approval.approve!
    approval
  end

  def approve!
    update(status: "accepted", approval_date: Time.current)
    user.approve_devices(approvable)
  end
end
