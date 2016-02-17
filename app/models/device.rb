class Device < ActiveRecord::Base
  include SlackNotifiable
  include SwitchFogging

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :permitted_users, through: :permissions, source: :permissible, :source_type => "User"

  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def checkins
    delayed? ? super.where("created_at < ?", delayed.minutes.ago) : super
  end

  def privilege_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s).privilege
  end

  def create_checkin(lat:, lng:)
    checkins << Checkin.create(uuid: uuid, lat: lat, lng: lng)
  end

  def slack_message
    "A new device has been created"
  end

end
