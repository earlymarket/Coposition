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
        ch.country_code,
        MIN(ch.created_at) OVER w as min_date,
        MAX(ch.created_at) OVER w as max_date
      FROM checkins as ch
      INNER JOIN
        devices ON ch.device_id = devices.id
      WHERE
        devices.user_id = #{user.id}
      WINDOW w AS (PARTITION BY ch.country_code)
      ORDER BY min_date DESC
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
      ORDER BY min_date DESC
    EOQ
  end
end
