class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins

  # scope :last_checkin, -> { checkins.last }

  def last_checkin
    checkins.last
  end
end


FIX DIS