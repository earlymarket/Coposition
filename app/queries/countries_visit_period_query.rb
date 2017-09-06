class CountriesVisitPeriodQuery
  attr_reader :user, :options

  def initialize(user:, **options)
    @user = user
    @options = options
  end

  def all
    query = <<-EOQ
      SELECT
        ch.country_code,
        min(ch.created_at) OVER w,
        max(ch.created_at) OVER w
      FROM checkins as ch
      INNER JOIN
        devices ON ch.device_id = devices.id
      WHERE
        devices.user_id = #{user.id}
      WINDOW w AS (PARTITION BY ch.country_code);
    EOQ

    ActiveRecord::Base.connection.execute(query)
  end
end
