class Checkin < ActiveRecord::Base
  include SwitchFogging

  validates :lat, presence: :true
  validates :lng, presence: :true
  belongs_to :device

  delegate :user, to: :device

  default_scope { order(created_at: :desc) }
  scope :since, -> (date) { where("created_at > ?", date)}
  scope :before, -> (date) { where("created_at < ?", date)}

  reverse_geocoded_by :lat, :lng do |obj,results|
    if results.present?
      results.first.methods.each do |m|
        obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
      end
    else
      obj.update(address: 'No address available')
    end
  end


  after_create do
    if device
      self.uuid = device.uuid
      self.fogged ||= device.fogged
      device.checkins << self
      reverse_geocode! if device.checkins.count == 1
      add_fogged_info
    else
      raise "Checkin is not assigned to a device." unless Rails.env.test?
    end
  end

  def replace_foggable_attributes
    if fogged? || device.fogged?
      fogged_checkin = Checkin.new(attributes.delete_if {|key, _v| key =~ /city|postal/ })
      fogged_checkin.assign_attributes(address: fogged_area, lat: fogged_lat, lng: fogged_lng)
      return fogged_checkin
    end
    self
  end

  def self.replace_foggable_attributes
    # this will convert it to an array
    # paginate before use!
    all.map {|checkin| checkin.replace_foggable_attributes }
  end

  def public_info
    assign_attributes(address: fogged_area) if address == 'Not yet geocoded'
    attributes.delete_if {|key, value| key =~ /fogged|uuid/ || value == nil}
  end

  def self.calendar_data
    since(first.created_at.beginning_of_year)
    .unscope(:order)
    .group("date_trunc('day', created_at)")
    .count
    .to_a
    .sort
  end

  def reverse_geocode!
    unless reverse_geocoded?
      reverse_geocode
      save
    end
    self
  end

  def reverse_geocoded?
    address != 'Not yet geocoded'
  end

  def nearest_city
    center_point = [self.lat, self.lng]
    City.near(center_point, 200).first || NoCity.new
  end

  def add_fogged_info
    self.fogged_lat ||= nearest_city.latitude || self.lat + rand(-0.5..0.5)
    self.fogged_lng ||= nearest_city.longitude || self.lng + rand(-0.5..0.5)
    self.fogged_area ||= nearest_city.name
    self.country_code ||= nearest_city.country_code
    save
  end

  def resolve_address(permissible, type)
    reverse_geocode! if type == "address"
    return replace_foggable_attributes.public_info unless device.can_bypass_fogging?(permissible)
    self.public_info
  end

  def self.resolve_address(permissible, type)
    includes(:device).map do |checkin|
      checkin.resolve_address(permissible, type)
    end
  end

  def self.hash_group_and_count_by(attribute)
    select(&attribute).group_by(&attribute)
    .each_with_object({}) do |(key,checkins), result|
      result[key] = checkins.count
    end
    .sort_by{ |_attribute, count| count }.reverse!
  end

  def self.percentage_increase(time_range)
    recent_checkins_count = where(created_at: 1.send(time_range).ago..Time.now).count.to_f
    older_checkins_count = where(created_at: 2.send(time_range).ago..1.send(time_range).ago).count.to_f
    if recent_checkins_count > 0 && older_checkins_count > 0
      (((recent_checkins_count/older_checkins_count)-1)*100).round(2)
    end
  end

  def self.to_csv
    attributes = Checkin.column_names

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |checkin|
        csv << checkin.attributes.values_at(*attributes)
      end
    end
  end
end
