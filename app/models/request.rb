class Request < ApplicationRecord
  include SlackNotifiable
  belongs_to :developer
  scope :recent, ->(time) { where('created_at > ?', time) }
  default_scope { order(created_at: :desc) }

  def slack_message
    return if (controller == 'api/v1/checkins' && action == 'create') || (controller == 'api/v1/users/requests')
    "A developer has made a new request, id: #{developer_id},"\
    " company name: #{Developer.find(developer_id).company_name},"\
    " controller: #{controller}, action: #{action}, user_id: #{user_id}."
  end
end
