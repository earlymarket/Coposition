class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def connection_code
    return super unless super.nil?
    code = []
    encrypted_password[0,6].each_byte do |byte|
      code << (byte % 3) + 1
    end
    str = code.join
    self.connection_code = str
    save
    "test"
  end
end
