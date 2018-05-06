class Request < ApplicationRecord
  belongs_to :developer
  scope :since, ->(time) { where("created_at > ?", time) }
  default_scope { order(created_at: :desc) }

  after_create { check_count if Rails.env.staging? }

  def check_count
    return unless Request.count > 2000
    Request.destroy(Request.last(200).pluck(:id))
  end
end
