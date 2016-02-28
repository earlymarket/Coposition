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

  def checkins_for(permissible)
    approval_date = user.approval_for(permissible).approval_date
    if permission_for(permissible).show_history
      checkins
    else
      checkins.where("created_at > ?", approval_date)
    end
  end

  def permission_for(permissible)
    permissions.find_by(permissible_id: permissible.id, permissible_type: permissible.class.to_s)
  end

  def slack_message
    "A new device has been created"
  end

end
