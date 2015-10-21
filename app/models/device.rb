class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins
  has_many :device_approved_developers
  has_many :approved_developers, through: :device_approved_developers,
    source: "developer"

end