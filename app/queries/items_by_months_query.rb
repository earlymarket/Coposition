class ItemsByMonthsQuery
  ACTIVE_USERS_BY_MONTHS = <<-ACTIVE_USERS
    (select MAX(c.created_at) as created_at, u.id
    from checkins as c
    join devices as d on d.id = c.device_id
    join users as u on u.id = d.user_id
    where (u.is_active = true)
    group by EXTRACT(MONTH from c.created_at), u.id)
  ACTIVE_USERS

  ACTIVE_USERS_CHECKINS = <<-ACTIVE_USERS_CHECKINS
    (select c.created_at as created_at, c.id
    from checkins as c
    join devices as d on d.id = c.device_id
    join users as u on u.id = d.user_id
    where (u.is_active = true))
  ACTIVE_USERS_CHECKINS

  ACTIVE_USERS = <<-ACTIVE_USERS
    (select *
    from users as u
    where (u.is_active = true))
  ACTIVE_USERS

  attr_reader :table, :options

  def initialize(**options)
    @options = options
  end

  def all
    query = <<-EOQ
      select
        month, total,
        (total::float / lag(total) over (order by month) - 1) * 100 as growth
      from (
        select to_char(ds.created_at, 'yyyy-mm') as month, count(ds.id) as total
        from #{data_source} as ds
        group by month
      ) s
      order by month desc;
    EOQ

    ActiveRecord::Base.connection.execute(query)
  end

  private

  def data_source
    if options[:active_users]
      ACTIVE_USERS_BY_MONTHS
    elsif options[:checkins]
      ACTIVE_USERS_CHECKINS
    else
      ACTIVE_USERS
    end
  end
end
