class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  has_many :devices

  # has_many :approvals, foreign_key: "user_id", class_name: "DevelopersUsers"
  has_many :approvals

  has_many :developers, through: :approvals

  def pending_approvals
    approvals.where(approved: false)
  end


end
