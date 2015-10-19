class Developer < ActiveRecord::Base
  include ApprovalMethods

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :approvals
  has_many :users, through: :approvals
  has_many :requests



  before_create do |dev|
    dev.api_key = generate_api_key
  end

  def generate_api_key
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless Developer.exists?(api_key: token)
    end
  end

  def approved_users
    approvals.where(approved: true)
  end

  def request_approval_from(user)
    approvals << Approval.create(developer: self, user: user)
  end
  





end
