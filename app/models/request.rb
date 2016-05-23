class Request < ActiveRecord::Base
  include SlackNotifiable
  belongs_to :developer
  scope :recent, ->(time) { where("created_at > ?", time) }
  default_scope { order(created_at: :desc) }

  def slack_message
    unless (controller == "api/v1/checkins" && action == "create") || (controller == "api/v1/users/requests")
      "A developer has made a new request, developer id: #{self.developer_id}, controller: #{self.controller}, action: #{self.action}, user_id: #{self.user_id}."
    end
  end
end
