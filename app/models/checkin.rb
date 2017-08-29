class GeojsonCheckin
  def initialize(record)
    @type = "Feature"
    @geometry = { "type": "Point", "coordinates": [record[1], record[0]] }
    @properties = { "id": record[2] }
  end
end

class Checkin < ApplicationRecord
  validates :lat, presence: :true, inclusion: { in: -90..90, message: "Latitude must be between -90 and 90" }
  validates :lng, presence: :true, inclusion: { in: -180..180, message: "longitude must be between -180 and 180" }

  belongs_to :device

  delegate :user, to: :device

  default_scope { order(created_at: :desc) }
  scope :since, ->(date) { where("created_at > ?", date) }

  before_update :set_edited, if: proc { lat_changed? || lng_changed? || created_at_changed? }


  reverse_geocoded_by :lat, :lng do |obj, results|
    if results.present?
      results.first.methods.each do |m|
        obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
        obj.send("output_#{m}=", results.first.send(m)) if (column_names.include? m.to_s) && !obj.fogged
      end
    else
      obj.update(address: "Not yet geocoded")
    end
  end

  after_create do
    if device
      reload
      assign_values
      save
    else
      raise "Checkin is not assigned to a device."
    end
  end

  def assign_values
    city = nearest_city
    assign_attributes(
      uuid: device.uuid,
      fogged: self.fogged ||= device.fogged,
      fogged_lat: city.latitude || lat + rand(-0.5..0.5),
      fogged_lng: city.longitude || lng + rand(-0.5..0.5),
      fogged_city: city.name,
      country_code: city.country_code,
      fogged_country_code: city.country_code
    )
    update_output
  end

  def update_output
    fogged ? assign_output_to_fogged : assign_output_to_unfogged
  end

  def assign_output_to_fogged
    assign_attributes(
      output_lat: fogged_lat,
      output_lng: fogged_lng,
      output_address: nil,
      output_city: fogged_city,
      output_postal_code: nil,
      output_country_code: fogged_country_code
    )
  end

  def assign_output_to_unfogged
    assign_attributes(
      output_lat: lat,
      output_lng: lng,
      output_address: address,
      output_city: city || fogged_city,
      output_postal_code: postal_code,
      output_country_code: country_code
    )
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
    address != "Not yet geocoded"
  end

  def set_edited
    write_attribute(:edited, true)
  end

  def refresh
    reverse_geocode
    assign_values
    save
  end

  def nearest_city
    City.near([lat, lng], 200).first || NoCity.new
  end

  class << self
    def limit_returned_checkins(args)
      if args[:action] == "index" && args[:multiple_devices]
        all
      elsif args[:action] == "index" && !args[:multiple_devices]
        paginate(page: args[:page], per_page: args[:per_page])
      else
        limit(1)
      end
    end

    def near_to(near)
      return all unless near
      near_array = near.split(",")
      lat = near_array[0].to_f
      lng = near_array[1].to_f
      where(lat: (lat - 0.5)..(lat + 0.5), lng: (lng - 0.5)..(lng + 0.5))
    end

    def since_time(time_amount, time_unit)
      return all unless time_unit && time_amount
      since(time_amount.to_i.send(time_unit).ago)
    end

    def on_date(date)
      return all unless date
      date = Date.parse(date)
      where(created_at: date.midnight..date.end_of_day)
    end

    def unique_places_only(unique_places)
      return all unless unique_places
      where("created_at IN(SELECT MAX(created_at) FROM checkins GROUP BY fogged_city)")
    end

    def hash_group_and_count_by(attribute)
      grouped_and_counted = unscope(:order).group(attribute).count
      grouped_and_counted.sort_by { |_attribute, count| count }.reverse
    end

    def percentage_increase(time_range)
      one_time_range_ago = 1.send(time_range).ago
      recent_checkins_count = where(created_at: one_time_range_ago..Time.now).count.to_f
      older_checkins_count = where(created_at: 2.send(time_range).ago..one_time_range_ago).count.to_f
      return unless [recent_checkins_count, older_checkins_count].all?(&:positive?)
      (((recent_checkins_count / older_checkins_count) - 1) * 100).round(2)
    end

    def to_csv
      attributes = Checkin.column_names

      CSV.generate(headers: true) do |csv|
        csv << attributes
        all.pluck(*attributes).each do |record|
          csv << record
        end
      end
    end

    def to_gpx
      GPX::GPXFile.new.tap do |gpx|
        gpx.routes << GPX::Route.new.tap do |route|
          all.pluck(:lat, :lng, :created_at).each do |record|
            route.points << GPX::Point.new(elevation: 0, lat: record[0], lon: record[1], time: record[2])
          end
        end
      end.to_s
    end

    def to_geojson
      {
        "type": "FeatureCollection",
        "features":
          [].tap do |geojson_checkins|
            all.pluck(:lat, :lng, :id).each do |record|
              geojson_checkins << GeojsonCheckin.new(record)
            end
          end
      }.to_json
    end
  end
end
