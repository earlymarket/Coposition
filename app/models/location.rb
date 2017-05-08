class Location < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :checkins
  has_many :devices, through: :checkins
  validates_presence_of :lat, :lng

  reverse_geocoded_by :lat, :lng

  def reverse_geocode!
    unless reverse_geocoded?
      reverse_geocode
      save
    end
    self
  end

  def reverse_geocoded?
    address?
  end

end
