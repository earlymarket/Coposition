module Users
  class CheckinsIndexPresenter < ApplicationPresenter
    FIRST_LOAD_MAX = 5_000
    MAX_CHECKINS_TO_DISPLAY = 20_000
    MAX_CHECKINS_TO_LOAD = 50_000

    attr_reader :user
    attr_reader :checkins
    attr_reader :filename
    attr_reader :date_range

    def initialize(user, params)
      @user = user
      @params = params
      @date_range = first_load && user.checkins.any? ? first_load_range : checkins_date_range
    end

    def index_gon
      {
        checkin: checkin,
        checkins: raw_paginated_checkins,
        cities: raw_cities,
        counts: gon_cities_counts,
        first_load: first_load,
        current_user_id: user.id,
        total: gon_show_checkins.count,
        max: MAX_CHECKINS_TO_LOAD
      }
    end

    def form_path
      user_checkins_path(user.url_id)
    end

    def form_range_filter(text, from)
      link_to text, user_checkins_path(user.url_id, from: from, to: Time.zone.today), method: :get
    end

    private

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
      return { from: nil, to: nil } if (checkins = gon_show_checkins).size.zero?

      { from: checkins.last.created_at.beginning_of_day, to: checkins.first.created_at.end_of_day }
    end

    def gon_show_checkins
      checkins = user.checkins

      @gon_show_checkins ||= if checkin
        checkins.where(id: checkin.id)
      elsif first_load && gon_show_cities.present?
        range = gon_show_cities.last.created_at.beginning_of_day..gon_show_cities.first.created_at.end_of_day
        checkins.where(created_at: range)
      elsif date_range[:from]
        checkins.where(created_at: date_range[:from]..date_range[:to])
      else
        checkins
      end
    end

    def gon_show_cities
      checkins = first_load ? user.checkins : gon_show_checkins
      checkins = Checkin.where(id: checkins.map(&:id))
      checkins = Checkin.where(id: checkins.unscope(:order).select("DISTINCT ON(fogged_city) *").map(&:id))
      first_load ? checkins.limit(100) : checkins
    end

    def raw_cities
      city_checkins_sql = gon_show_cities.select("created_at", "fogged_lat AS lat", "fogged_lng AS lng",
        "fogged_city AS city", "fogged_country_code AS country_code", "null AS id").to_sql
      ActiveRecord::Base.connection.execute(city_checkins_sql)
    end

    def gon_cities_counts
      gon_show_checkins.unscope(:order).group(:fogged_city).count
    end
  end
end
