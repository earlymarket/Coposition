class Checkin < ApplicationRecord
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
        obj.send("output_#{m}=", results.first.send(m)) if (column_names.include? m.to_s) && !obj.fogged
      end
    else
      obj.update(address: 'No address available')
    end
  end

  after_create do
    if device
      update({
        uuid: device.uuid,
        fogged: fogged ||= device.fogged
      })
      reverse_geocode! if device.checkins.count == 1
      init_fogged_info
      fogged ? set_output_to_fogged : set_output_to_unfogged
    else
      raise 'Checkin is not assigned to a device.' unless Rails.env.test?
    end
  end

  def self.limit_returned_checkins(args)
    per_page = all.length > 1 ? args[:per_page] : 1
    if args[:action] == 'index' && args[:multiple_devices]
      limit(per_page)
    elsif args[:action] == 'index' && !args[:multiple_devices]
      paginate(page: args[:page], per_page: per_page)
    else
      limit(1)
    end
  end

  def replace_foggable_attributes
    if device.fogged? || fogged?
      fogged_checkin = Checkin.new(attributes.delete_if { |key, _v| key =~ /city|postal/ })
      fogged_checkin.assign_attributes(address: fogged_city, lat: fogged_lat, lng: fogged_lng)
      return fogged_checkin
    end
    self
  end

  def self.replace_foggable_attributes
    # this will convert it to an array, paginate before use!
    all.map(&:replace_foggable_attributes)
  end

  def public_info
    assign_attributes(address: fogged_city) if address == 'Not yet geocoded'
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

  def init_fogged_info
    update({
      fogged_lat: nearest_city.latitude || lat + rand(-0.5..0.5),
      fogged_lng: nearest_city.longitude || lng + rand(-0.5..0.5),
      fogged_city: nearest_city.name,
      fogged_country_code: nearest_city.country_code
    })
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

  def switch_fog
    update(fogged: !fogged)
    fogged ? set_output_to_fogged : set_output_to_unfogged
  end

  def set_output_to_fogged
    update({
      output_lat: fogged_lat,
      output_lng: fogged_lng,
      output_address: nil,
      output_city: fogged_city,
      output_postal_code: nil,
      output_country_code: fogged_country_code
    })
  end

  def set_output_to_unfogged
    update({
      output_lat: lat,
      output_lng: lng,
      output_address: address,
      output_city: city,
      output_postal_code: postal_code,
      output_country_code: country_code
    })
  end

end
