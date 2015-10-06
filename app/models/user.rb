class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  include ApprovalMethods

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  validates :username, uniqueness: true 
  validates :username, format: { with: /\A[-a-zA-Z_]+\z/,
    message: "only allows letters, underscores and dashes" }

  has_many :devices
  has_many :approvals
  has_many :developers, through: :approvals

  def notifications
    x = []
    if pending_approvals.present?
      x << {
        notification: {
            msg: "You have #{pending_approvals.count} pending approvals",
            link_path: "user_approvals_path"
          }
        }
    end
    x
  end

end