class Permission < ApplicationRecord
  belongs_to :device
  belongs_to :permissible, polymorphic: true

  before_create { |p| p.privilege = :complete }

  enum privilege: [:disallowed, :last_only, :complete]
end
