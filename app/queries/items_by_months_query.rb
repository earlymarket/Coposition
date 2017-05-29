class ItemsByMonthsQuery
  attr_reader :table, :options

  def initialize(table:, **options)
    @table = table
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
      order by month;
    EOQ

    ActiveRecord::Base.connection.execute(query)
  end

  private

  def data_source
    if options[:active_users]
      active_users_by_months
    else
      table
    end
  end

  def active_users_by_months
    <<-ACTIVE_USERS
      (select MAX(c.created_at) as created_at, u.id
      from checkins as c
      join devices as d on d.id = c.device_id
      join users as u on u.id = d.user_id
      group by EXTRACT(MONTH from c.created_at), u.id)
    ACTIVE_USERS
  end
end
