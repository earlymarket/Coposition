class Developer < ActiveRecord::Base
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
    approvals.where(approved: false)
  end

  def approved_users
    approvals.where(approved: true)
  end

  def request_approval_from(user)
    approvals << Approval.create(user: user)
  end


end
