class ItemsByMonthsQuery
  attr_reader :table

  def initialize(table:)
    @table = table
  end

  def all
    query = <<-EOQ
      select
          month, total,
          (total::float / lag(total) over (order by month) - 1) * 100 as growth
      from (
          select to_char(created_at, 'yyyy-mm') as month, count(id) as total
          from #{table}
          group by month
      ) s
      order by month;
    EOQ

    ActiveRecord::Base.connection.execute(query)
  end
end
