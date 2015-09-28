class Approval < ActiveRecord::Base

  before_create do |app|
    app.approved = false
    !Approval.exists?(user: user, developer: developer)
  end

  belongs_to :user
  belongs_to :developer

  def approve!
    update(approved: true)
  end

  def reject!
    update(approved: false)
  end

end