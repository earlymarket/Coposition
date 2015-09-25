class User < ActiveRecord::Base
  include ApprovalMethods

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  has_many :devices
  has_many :approvals
  has_many :developers, through: :approvals

end
