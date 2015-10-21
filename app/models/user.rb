class User < ActiveRecord::Base
  extend FriendlyId
  include ApprovalMethods

  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  validates :username, uniqueness: true 
  validates :username, format: { with: /\A[-a-zA-Z_]+\z/,
    message: "only allows letters, underscores and dashes" }

  has_many :devices
  has_many :approvals
  has_many :developers, through: :approvals


  ## Approvals

  def approved_developers
    approvals.where(approved: true)
  end


  def approve_developer(dev)
    app = approvals.where(approved: false, developer: dev).first
    unless app
      return false
    end
    app.approved = true
    app.pending = false
    approve_devices_for_developer(dev)
    app.save
  end

  def approved_developer?(dev)
    app = approvals.where(developer: dev).first
    app && app.approved?
  end

  ##############


  ## Devices

  def approve_devices_for_developer(developer)
    devices.each do |device|
      device.developers << developer
    end
  end

  ##############



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