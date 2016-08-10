require 'active_support/concern'
require 'slack-notifier'

module SlackNotifiable
  extend ActiveSupport::Concern

  included do
    after_create :ping_slack if Rails.env.production?
  end

  def ping_slack
    return unless slack_message
    Slack::Notifier.new(Rails.application.secrets.webhook_url, channel: '#dev', username: 'Coposition Event')
                   .ping(slack_message)
  end
end
