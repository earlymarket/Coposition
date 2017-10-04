module Users::Devices
  class DevicesShowPresenter < ApplicationPresenter
    FIRST_LOAD_MAX = 5_000
    MAX_CHECKINS_TO_DISPLAY = 20_000
    MAX_CHECKINS_TO_LOAD = 50_000

    attr_reader :user
    attr_reader :device
    attr_reader :checkins
    attr_reader :filename
    attr_reader :date_range
    attr_reader :checkins_view

    def initialize(user, params)
      @user = user
      @params = params
      @device = Device.find(params[:id])
      @checkins_view = params[:checkins_view] == "true"
      @date_range = first_load && device.checkins.any? ? first_load_range : checkins_date_range

      set_data_for_download if download_format.present?
    end

    def show_gon
      {
        checkin: checkin,
        checkins: raw_paginated_checkins,
        cities: gon_show_cities,
        counts: gon_cities_counts,
        first_load: first_load,
        device: device.id,
        current_user_id: user.id,
        total: gon_show_checkins.count,
        max: MAX_CHECKINS_TO_LOAD,
        checkins_view: checkins_view
      }
    end

    def form_for
      device
    end

    def form_path
      user_device_path(user.url_id, device)
    end

    def form_range_filter(text, from)
      link_to text, user_device_path(user.url_id, device, from: from, to: Time.zone.today), method: :get
    end

    private

    def set_data_for_download
      @filename = "device-#{device.id}-checkins-#{DateTime.current}." + download_format
      @checkins = gon_show_checkins.send("to_" + download_format)
    end

    def download_format
      @downlod_format ||= params[:download]
    end

    def first_load
      @first_load ||= params[:first_load]
    end

    def checkin
      @checkin ||= params[:checkin_id] ? Checkin.find(params[:checkin_id]) : nil
    end

    def gon_show_checkins_paginated
      gon_show_checkins
        .paginate(page: 1, per_page: 5000)
        .select(:id, :lat, :lng, :created_at, :address, :fogged, :fogged_city, :edited)
    end

    def raw_paginated_checkins
      if gon_show_checkins.count <= MAX_CHECKINS_TO_DISPLAY
        ActiveRecord::Base.connection.execute(gon_show_checkins_paginated.to_sql).to_a
      else
        []
      end
    end

    def first_load_range
      return { from: nil, to: nil } if (checkins = device.checkins.limit(FIRST_LOAD_MAX)).size.zero?

      { from: checkins.last.created_at.beginning_of_day, to: Time.zone.today }
    end

    def gon_show_checkins
      checkins = device.checkins

      @gon_show_checkins ||= if checkin
        checkins.where(id: checkin.id)
      elsif first_load
        checkins.limit(FIRST_LOAD_MAX)
      elsif date_range[:from]
        checkins.where(created_at: date_range[:from]..date_range[:to])
      else
        checkins
      end
    end

    def gon_show_cities
      checkins = first_load ? gon_show_checkins.where(id: gon_show_checkins.select(:id)) : gon_show_checkins
      city_checkins = Checkin.where(id: checkins.unscope(:order).select("DISTINCT ON(fogged_city) *").map(&:id))
      city_checkins_sql = city_checkins.select("created_at", "fogged_lat AS lat", "fogged_lng AS lng",
        "fogged_city AS city", "fogged_country_code AS country_code", "null AS id").to_sql
      ActiveRecord::Base.connection.execute(city_checkins_sql)
    end

    def gon_cities_counts
      gon_show_checkins.where(id: gon_show_checkins.select(:id)).unscope(:order).group(:fogged_city).count
    end
  end
end
