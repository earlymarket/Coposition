class Request < ApplicationRecord
  belongs_to :developer
  scope :since, ->(time) { where("created_at > ?", time) }
  default_scope { order(created_at: :desc) }
end
