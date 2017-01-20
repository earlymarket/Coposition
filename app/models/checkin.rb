class Checkin < ApplicationRecord
  validates :lat, presence: :true
  validates :lng, presence: :true
  belongs_to :device

  delegate :user, to: :device

  default_scope { order(created_at: :desc) }
  scope :since, ->(date) { where('created_at > ?', date) }
  scope :before, ->(date) { where('created_at < ?', date) }

  before_update :set_edited, if: proc { lat_changed? || lng_changed? }

  reverse_geocoded_by :lat, :lng do |obj, results|
    if results.present?
      results.first.methods.each do |m|
        obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
        obj.send("output_#{m}=", results.first.send(m)) if (column_names.include? m.to_s) && !obj.fogged
      end
    else
      obj.update(address: 'Not yet geocoded')
    end
  end

  after_create do
    if device
      city = nearest_city
      update(
        uuid: device.uuid,
        fogged: self.fogged ||= device.fogged,
        fogged_lat: city.latitude || lat + rand(-0.5..0.5),
        fogged_lng: city.longitude || lng + rand(-0.5..0.5),
        fogged_city: city.name,
        country_code: city.country_code,
        fogged_country_code: city.country_code
      )
      reverse_geocode! if device.checkins.count == 1
      fogged ? set_output_to_fogged : set_output_to_unfogged
    else
      raise 'Checkin is not assigned to a device.' unless Rails.env.test?
    end
  end

  def self.batch_create(post_content)
    Checkin.transaction do
      JSON.parse(post_content).each do |checkin_hash|
        checkin = Checkin.create(checkin_hash.slice('lat', 'lng', 'created_at', 'fogged'))
        raise ActiveRecord::Rollback unless checkin.save
        checkin.device.notify_subscribers('new_checkin', checkin)
      end
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

  def reverse_geocode!
    unless reverse_geocoded?
      reverse_geocode
      update_output
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

  def refresh
    reverse_geocode
    save
    init_fogged_info
    fogged || device.fogged ? set_output_to_fogged : set_output_to_unfogged
  end

  def init_fogged_info
    city = nearest_city
    update(
      fogged_lat: city.latitude || lat + rand(-0.5..0.5),
      fogged_lng: city.longitude || lng + rand(-0.5..0.5),
      fogged_city: city.name,
      country_code: city.country_code,
      fogged_country_code: city.country_code
    )
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
    where('created_at IN(SELECT MAX(created_at) FROM checkins GROUP BY fogged_city)')
  end

  def self.hash_group_and_count_by(attribute)
    grouped_and_counted = unscope(:order).group(attribute).count
    grouped_and_counted.sort_by { |_attribute, count| count }.reverse
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

  def switch_fog
    update(fogged: !fogged)
    return if device.fogged
    fogged ? set_output_to_fogged : set_output_to_unfogged
  end

  def update_output
    if fogged || device.fogged
      set_output_to_fogged
    else
      set_output_to_unfogged
    end
  end

  def set_output_to_fogged
    update(
      output_lat: fogged_lat,
      output_lng: fogged_lng,
      output_address: nil,
      output_city: fogged_city,
      output_postal_code: nil,
      output_country_code: fogged_country_code
    )
  end

  def set_output_to_unfogged
    update(
      output_lat: lat,
      output_lng: lng,
      output_address: address,
      output_city: city,
      output_postal_code: postal_code,
      output_country_code: country_code
    )
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

  def set_edited
    write_attribute(:edited, true)
  end

end
