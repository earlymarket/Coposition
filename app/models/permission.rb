class Permission < ApplicationRecord
  belongs_to :device
  belongs_to :permissible, polymorphic: true

  before_create { |p| p.privilege = :last_only }

  enum privilege: [:disallowed, :last_only, :complete]

  def coposition_developer?
    return false unless permissible_type == 'Developer'
    key = Developer.find(permissible_id).api_key
    key == Rails.application.secrets['coposition_api_key'] || key == Rails.application.secrets['mobile_app_api_key']
  end

  def self.not_coposition_developers
    copo_ids = Developer.coposition_developers.select(:id)
    Permission.where.not(['permissible_type = ? AND permissible_id IN (?)', 'Developer', copo_ids])
  end
end
