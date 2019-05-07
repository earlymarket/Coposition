class CountriesVisitPeriodQuery
  attr_reader :user, :options
  FLIGHT_ALTITUDE = 8_000

  def initialize(user:, **options)
    @user = user
    @options = options
  end

  def full_history
    ActiveRecord::Base.connection.execute(full_history_query)
  end

  def last_visited
    ActiveRecord::Base.connection.execute(last_visited_query)
  end

  private

  def full_history_query
    <<-EOQ
      SELECT
        visits.country_code, visits.min_date, visits.max_date
      FROM (
        SELECT
          grouped_ch.country_code,
          MIN(grouped_ch.created_at) OVER w as min_date,
          MAX(grouped_ch.created_at) OVER w as max_date
        FROM (
          SELECT numbered_ch.*,
            (numbered_ch.rnum - row_number() OVER (PARTITION BY numbered_ch.country_code ORDER BY numbered_ch.rnum)) as grp
          FROM (
            SELECT ordered_ch.*, (row_number() OVER()) as rnum
            FROM (
              SELECT *
              FROM checkins
              INNER JOIN
                devices ON checkins.device_id = devices.id
              WHERE
                devices.user_id = #{user.id}
              AND checkins.created_at <= current_timestamp
              AND (checkins.altitude != 0 OR checkins.altitude IS NULL)
              AND (checkins.altitude <= #{FLIGHT_ALTITUDE} OR checkins.altitude IS NULL)
              ORDER BY created_at
            ) as ordered_ch
          ) as numbered_ch
        ) as grouped_ch
        WINDOW w AS (PARTITION BY grouped_ch.country_code, grouped_ch.grp)
      ) as visits
      GROUP BY
        visits.country_code, visits.min_date, visits.max_date
      ORDER BY visits.max_date DESC
    EOQ
  end

  def last_visited_query
    <<-EOQ
      SELECT
        last_visits.country_code,
        MAX(last_visits.max_date) as max_date,
        MAX(last_visits.min_date) as min_date
      FROM (#{full_history_query}) last_visits
      GROUP BY last_visits.country_code
      ORDER BY max_date DESC
    EOQ
  end
end
