class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  has_many :devices
  has_many :approvals
  has_many :developers, through: :approvals

  def pending_approvals
    approvals.where(approved: false)
  end

  def approved_developers
    approvals.where(approved: true)
  end

  def approve_developer(dev)
    app = approvals.where(approved: false, developer: dev).first
    app.approved = true
    app.save
  end

end
