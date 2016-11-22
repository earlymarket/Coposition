class Checkin < ApplicationRecord
  include SwitchFogging
  validates :lat, presence: :true
  validates :lng, presence: :true
  belongs_to :device

  delegate :user, to: :device

  default_scope { order(created_at: :desc) }
  scope :since, -> (date) { where('created_at > ?', date) }
  scope :before, -> (date) { where('created_at < ?', date) }

  reverse_geocoded_by :lat, :lng do |obj, results|
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
      reverse_geocode! if device.checkins.count == 1
      add_fogged_info
    else
      raise 'Checkin is not assigned to a device.' unless Rails.env.test?
    end
  end

  def self.limit_returned_checkins(args)
    if args[:action] == 'index' && args[:multiple_devices]
      all
    elsif args[:action] == 'index' && !args[:multiple_devices]
      paginate(page: args[:page], per_page: args[:per_page])
    else
      limit(1)
    end
  end

  def replace_foggable_attributes
    if device.fogged? || fogged?
      fogged_checkin = Checkin.new(attributes.delete_if { |key, _v| key =~ /city|postal/ })
      fogged_checkin.assign_attributes(address: fogged_area, lat: fogged_lat, lng: fogged_lng)
      return fogged_checkin
    end
    self
  end

  def self.replace_foggable_attributes
    # this will convert it to an array, paginate before use!
    all.map(&:replace_foggable_attributes)
  end

  def public_info
    assign_attributes(address: fogged_area) if address == 'Not yet geocoded'
    attributes.delete_if { |key, value| key =~ /fogged|uuid/ || value.nil? }
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
    City.near([lat, lng], 200).first || NoCity.new
  end

  def add_fogged_info
    random_distance = rand(-0.5..0.5)
    self.fogged_lat = nearest_city.latitude || lat + random_distance
    self.fogged_lng = nearest_city.longitude || lng + random_distance
    self.fogged_area = nearest_city.name
    self.country_code = nearest_city.country_code
    save
  end

  def self.near_to(near)
    return all unless near
    near_array = near.split(',')
    lat = near_array[0].to_f
    lng = near_array[1].to_f
    where(lat: (lat - 0.5)..(lat + 0.5), lng: (lng - 0.5)..(lng + 0.5))
  end

  def self.since_time(time_amount, time_unit)
    return all unless time_unit && time_amount
    since(time_amount.to_i.send(time_unit).ago)
  end

  def self.on_date(date)
    return all unless date
    date = Date.parse(date)
    where(created_at: date.midnight..date.end_of_day)
  end

  def self.unique_places_only(unique_places)
    return all unless unique_places
    checkins = unscope(:order).select('DISTINCT ON (checkins.fogged_area) *')
                              .sort { |checkin, next_checkin| next_checkin['created_at'] <=> checkin['created_at'] }
    all.where(id: checkins.map(&:id))
  end

  def self.hash_group_and_count_by(attribute)
    grouped_and_counted = select(&attribute)
                          .group_by(&attribute)
                          .each_with_object({}) { |(key, checkins), result| result[key] = checkins.count }
    grouped_and_counted.sort_by { |_attribute, count| count }.reverse!
  end

  def self.percentage_increase(time_range)
    one_time_range_ago = 1.send(time_range).ago
    recent_checkins_count = where(created_at: one_time_range_ago..Time.now).count.to_f
    older_checkins_count = where(created_at: 2.send(time_range).ago..one_time_range_ago).count.to_f
    return unless [recent_checkins_count, older_checkins_count].all? { |count| count > 0 }
    (((recent_checkins_count / older_checkins_count) - 1) * 100).round(2)
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

  def self.to_gpx
    gpx = GPX::GPXFile.new
    route = GPX::Route.new
    all.each do |checkin|
      route.points << GPX::Point.new(elevation: 0, lat: checkin.lat, lon: checkin.lng, time: checkin.created_at)
    end
    gpx.routes << route
    gpx.to_s
  end

  def self.to_geojson
    geojson_checkins = []
    all.each do |checkin|
      geojson_checkins << GeojsonCheckin.new(checkin)
    end
    geojson_checkins.as_json
  end
end
