class Developer < ApplicationRecord
  include ApprovalMethods, SlackNotifiable

  PUBLIC_ATTRIBUTES = %i(id email company_name tagline redirect_url)

  has_attachment :avatar

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  validates :email, confirmation: true
  
  has_one :oauth_application, class_name: "Doorkeeper::Application", as: :owner, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :permissions, as: :permissible, dependent: :destroy
  has_many :devices, through: :permissions
  has_many :subscriptions, as: :subscriber, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many :pending_requests, -> { where "status = 'developer-requested'" }, through: :approvals, source: :user
  has_many :users, -> { where "status in (?)", %w[accepted complete] }, through: :approvals
  has_many :configs
  has_many :configurable_devices, through: :configs, source: :device

  before_create do |dev|
    dev.api_key ||= SecureRandom.uuid
  end

  after_create do |dev|
    app = Doorkeeper::Application.new(name: dev.company_name, redirect_uri: dev.redirect_url)
    app.owner = dev
    app.save
  end

  after_update :set_application_attributes, if: proc { redirect_url_changed? || company_name_changed? }

  def self.default(type)
    key = type[:coposition] ? "coposition_api_key" : "mobile_app_api_key"
    FactoryGirl.create(:developer, api_key: Rails.application.secrets[key]) if Rails.env.test? || Rails.env.benchmark?
    find_by(api_key: Rails.application.secrets[key])
  end

  def self.public_info
    all.select(PUBLIC_ATTRIBUTES)
  end

  def slack_message
    "A new developer registered, id: #{id}, company_name: #{company_name}, there are now #{Developer.count} developers."
  end

  def public_info
    Developer.select(PUBLIC_ATTRIBUTES).find(id)
  end

  def subscribed_to(event)
    subscriptions.find_by(event: event)
  end

  def notify_if_subscribed(event, data)
    return unless zapier_enabled? && (sub = subscribed_to event)
    sub.send_data(data)
  end

  def configures_device?(device)
    configs.where(device: device).present?
  end

  def self.not_coposition_developers
    copo_keys = [Rails.application.secrets["coposition_api_key"], Rails.application.secrets["mobile_app_api_key"]]
    where.not(api_key: copo_keys)
  end

  def set_application_attributes
    oauth_application.update(name: company_name, redirect_uri: redirect_url)
  end

  def api_requests(user)
    requests.where(user_id: user.id).order(created_at: :desc)
  end
end
