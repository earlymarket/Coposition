class EmailRequest < ApplicationRecord
  belongs_to :user
  validates :user_id, uniqueness: { scope: :email }
end
