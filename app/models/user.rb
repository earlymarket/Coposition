class User < ActiveRecord::Base
  extend FriendlyId
  include ApprovalMethods
  include SlackNotifiable

  acts_as_token_authenticatable

  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :authentication_keys => { username: false, email: true }

  validates :username, uniqueness: true, 
                       allow_blank: true, 
                       format: { with: /\A[-a-zA-Z_]+\z/, 
                         message: "only allows letters, underscores and dashes" }

  has_many :devices, dependent: :destroy
  has_many :approvals, dependent: :destroy
  has_many :developers, through: :approvals

  ## Pathing

  def url_id
    username.empty? ? id : username
  end

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
      device.developers << developer unless device.developers.include? developer
    end
  end

  ################

  ## Metadata

  def devices_coords_at(param, range)
    coords = {}
    devices.each do |device|
      coords[device.name] = device.most_frequent_coords_over(param, range)
    end
    coords
  end

  def checkins
    checkins = []
    devices.each do |device|
      checkins << device.checkins
    end
    checkins.flatten
  end

  def last_checkin
    last_checkins = []
    devices.each do |device|
      last_checkins << device.checkins.last
    end
    last_checkins.sort_by(&:created_at).last
  end

  def most_used_device
    device_uses = {}
    devices.each do |device|
      device_uses[device] = device.checkins.count
    end
    device_uses.max_by{|_k,v| v}[0]
  end

  def last_used_device
    Device.find(last_checkin.device_id)
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