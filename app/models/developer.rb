class Developer < ActiveRecord::Base
  include ApprovalMethods

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




end
