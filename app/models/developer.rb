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
  has_many :device_developer_privileges, dependent: :destroy
  has_many :devices, through: :device_developer_privileges

  has_many :approvals, :as => :approvable, dependent: :destroy
  has_many :users, -> { where "status = 'accepted'" }, through: :approvals

  before_create do |dev|
    dev.api_key = SecureRandom.uuid
  end

  def request_approval_from(user)
    approvals << Approval.create(user_id: user.id, approvable_id: self.id, approvable_type: 'Developer', status: 'developer-requested')
  end

  def slack_message
    "A new developer has registered, there are now #{Developer.count} developers."
  end

  def approved_users
    approvals.where(status: 'accepted')
  end

end
