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


  has_many :approvals
  has_many :users, through: :approvals
  has_many :requests


  before_create do |dev|
    dev.api_key = SecureRandom.uuid
  end

  def approved_users
    approvals.where(approved: true)
  end

  def request_approval_from(user)
    approvals << Approval.create(developer: self, user: user)
  end
  
  def slack_message
    "A new developer has registered, there are now #{Developer.count} developers."
  end


end
