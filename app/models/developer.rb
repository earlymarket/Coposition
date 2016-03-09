class Developer < ActiveRecord::Base
  include ApprovalMethods
  include SlackNotifiable

  has_attached_file :logo,
    styles: { medium: "300x300>", thumb: "60x60>" }, default_url: "missing.png"
  validates_attachment :logo,
    content_type: { content_type: ["image/jpeg", "image/png"] },
    size: { in: 0..1.megabytes }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :requests, dependent: :destroy
  has_many :permissions, :as => :permissible, dependent: :destroy
  has_many :devices, through: :permissions

  has_many :approvals, :as => :approvable, dependent: :destroy
  has_many :pending_requests, -> { where "status = 'developer-requested'" }, :through => :approvals, source: :user
  has_many :users, -> { where "status = 'accepted'" }, through: :approvals

  before_create do |dev|
    dev.api_key = SecureRandom.uuid
  end

  def slack_message
    "A new developer has registered, id: #{self.id}, company_name: #{self.company_name}, there are now #{Developer.count} developers."
  end

  def approval_for(user)
    approvals.find_by(user_id: user.id) || NoApproval.new
  end

end
