class CountriesVisitPeriodQuery
  attr_reader :user, :options

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
        _ch.country_code, _ch.min_date, _ch.max_date
      FROM (
        SELECT
          __ch.country_code,
          MIN(__ch.created_at) OVER w as min_date,
          MAX(__ch.created_at) OVER w as max_date
        FROM (
          SELECT *, (id - row_number() OVER (PARTITION BY country_code)) as grp
          FROM checkins
          ORDER BY created_at
        ) as __ch
        INNER JOIN
          devices ON __ch.device_id = devices.id
        WHERE
          devices.user_id = 5
        WINDOW w AS (PARTITION BY __ch.country_code, __ch.grp)
      ) as _ch
      GROUP BY
        _ch.country_code, _ch.min_date, _ch.max_date
      ORDER BY _ch.max_date DESC
    EOQ
  end

  def last_visited_query
    <<-EOQ
      SELECT
        ch.country_code,
        MAX(ch.max_date) as max_date,
        MAX(ch.min_date) as min_date
      FROM (#{full_history_query}) ch
      GROUP BY ch.country_code
      ORDER BY ch.max_date DESC
    EOQ
  end
end
