class User < ActiveRecord::Base
  extend FriendlyId
  include ApprovalMethods
  include SlackNotifiable

  acts_as_token_authenticatable

  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :authentication_keys => { username: true, email: false }

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
    app.approve!
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

  def approved_devices_for_developer(developer)
    devices.where(developer: developer)
  end

  ################

  ## Metadata

  def workplace_address
    addresses = {}
    devices.each do |device|
      addresses[device.name] = device.most_frequent_address_over('hour', 8..17)
    end
    addresses
  end

  def checkins
    checkins = []
    devices.each do |device|
      checkins << device.checkins
    end
    checkins.flatten
  end

  def most_used_device
    device_uses = {}
    devices.each do |device|
      device_uses[device] = device.checkins.count
    end
    device_uses.max_by{|k,v| v}[0]
  end

  ##############

  def slack_message
    "A new user has registered, there are now #{User.count} users."
  end

  def notifications
    @notes ||= begin
      @notes = []
      if pending_approvals.present?
        @notes << {
          notification: {
              msg: "You have #{pending_approvals.count} pending approvals",
              link_path: "user_approvals_path"
            }
          }
      end
      @notes
    end
  end

end