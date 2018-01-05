class Permission < ApplicationRecord
  include PublicActivity::Common

  PRIVELEGE_TYPES = %i(disallowed last_only complete).freeze

  belongs_to :device
  belongs_to :permissible, polymorphic: true

  before_create { |p| p.privilege = :last_only }

  enum privilege: PRIVELEGE_TYPES

  default_scope { self.active_users }

  def self.not_coposition_developers
    keys = [Rails.application.secrets["coposition_api_key"], Rails.application.secrets["mobile_app_api_key"]]
    copo_dev_ids = Developer.where(api_key: keys).select :id
    Permission.where.not(["permissible_type = ? AND permissible_id IN (?)", "Developer", copo_dev_ids])
  end

  def self.active_users
    inactive_users_ids = User.where(is_active: false).select :id
    Permission.where.not(["permissible_type = ? AND permissible_id IN (?)", "User", inactive_users_ids])
  end
end
