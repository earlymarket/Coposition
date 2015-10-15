class Device < ActiveRecord::Base
  belongs_to :user
  has_many :checkins
  has_many :redbox_checkins
end