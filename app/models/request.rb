class Request < ActiveRecord::Base
  belongs_to :developer
  scope :recent, ->(time) { where("created_at > ?", time) }
end
