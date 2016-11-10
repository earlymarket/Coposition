class Developer < ApplicationRecord
  include ApprovalMethods, SlackNotifiable

  has_attachment :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :requests, dependent: :destroy
  has_many :permissions, as: :permissible, dependent: :destroy
  has_many :devices, through: :permissions
  has_many :subscriptions, as: :subscriber, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many :pending_requests, -> { where "status = 'developer-requested'" }, through: :approvals, source: :user
  has_many :users, -> { where "status = 'accepted'" }, through: :approvals
  has_many :configs
  has_many :configurable_devices, through: :configs, source: :device

  before_create do |dev|
    dev.api_key = SecureRandom.uuid
  end

  def slack_message
    "A new developer registered, id: #{id}, company_name: #{company_name}, there are now #{Developer.count} developers."
  end

  def public_info
    Developer.select([:id, :email, :company_name, :tagline, :redirect_url]).find(id)
  end

  def self.public_info
    all.select([:id, :email, :company_name, :tagline, :redirect_url])
  end

  def subscribed_to?(event)
    subscriptions.find_by(event: event)
  end

  def notify_if_subscribed(event, data)
    return unless (sub = subscribed_to? event)
    sub.send_data(data)
  end

  def configures_device?(device)
    configs.where(device: device).present?
  end

  def self.default(type)
    return FactoryGirl.create(:developer) if Rails.env.test?
    key = type[:coposition] ? 'coposition_api_key' : 'mobile_app_api_key'
    find_by(api_key: Rails.application.secrets[key])
  end
end
