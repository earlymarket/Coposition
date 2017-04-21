class Location < ApplicationRecord
  belongs_to :user
  has_many :checkins

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
