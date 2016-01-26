class Device < ActiveRecord::Base
  include SlackNotifiable
  include SharedMethods

  belongs_to :user
  has_many :checkins, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :developers, -> { where "privilege = 0" }, through: :permissions, source: :permissible, :source_type => "Developer"
  has_many :permitted_users, -> { where "privilege = 3" }, through: :permissions, source: :permissible, :source_type => "User"


  before_create do |dev|
    dev.uuid = SecureRandom.uuid
  end

  def checkins
    delayed? ? super.where("created_at < ?", delayed.minutes.ago) : super
  end

  def privilege_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s).privilege
  end

  def reverse_privilege_for(permissible)
    if privilege_for(permissible) == "complete"
      "disallowed"
    else
      "complete"
    end
  end

  def create_checkin(lat:, lng:)
    checkins << Checkin.create(uuid: uuid, lat: lat, lng: lng)
  end

  def change_privilege_for(permissible, new_privilege)
    if permissible.respond_to? :id
      perm = permissible.id
    end
    record = permissions.find_by(permissible_id: perm, permissible_type: permissible.class.to_s)
    record.privilege = new_privilege
    record.save
  end

  def device_checkin_hash
    hash = as_json
    hash[:last_checkin] = checkins.last.get_data if checkins.exists?
    hash
  end

  def slack_message
    "A new device has been created"
  end

end