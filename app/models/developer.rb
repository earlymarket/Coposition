class Developer < ActiveRecord::Base
  # include ApprovalMethods

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :approvals
  has_many :users, through: :approvals



  before_create do |dev|
    dev.api_key = generate_api_key
  end

  def generate_api_key
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless Developer.exists?(api_key: token)
    end
  end

  def pending_approvals
    approvals.where(pending: true)
  end

  def approved_users
    approvals.where(approved: true)
  end
  
  def approval_status_for(model)
    app = approvals.where({ model.class.to_s.downcase.to_sym => model }).first
    app.approved? if app
  end

  def request_approval_from(user)
    approvals << Approval.create(developer: self, user: user)
  end
  





end
