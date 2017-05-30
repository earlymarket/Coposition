ActiveAdmin.register_page "Device Distribution" do
  DEVICE_NUMBERS = [0, 1, 2, 3, 4, 5]
  DISTRIBUTION_TYPES = %i(full active).freeze

  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      DISTRIBUTION_TYPES.each do |type|
        params[type] = public_send("#{type}_distribution")
      end
    end

    def full_distribution
      build_collection(full_device_distribution, User.count)
    end

    def active_distribution
      total = ActiveRecord::Base.connection.execute(
        "select distinct ds.id from #{ItemsByMonthsQuery::ACTIVE_USERS_BY_MONTHS} ds"
      ).count

      build_collection(active_device_distribution, total)
    end

    private

    def build_collection(distribution, total)
      [].tap do |collection|
        DEVICE_NUMBERS.each do |number|
          distr = distribution.select{ |item| item["dev_count"] == number }.size
          collection << new_item(number, distr, total)
        end

        distr = distribution.select{ |item| item["dev_count"] > DEVICE_NUMBERS.last }.size
        collection << new_item("6+", distr, total)
      end
    end

    def new_item(number, distr, total)
      {
        devices: number,
        consumers: distr,
        percent: total.zero? ? "n/a" : distr * 100 / total
      }
    end

    def full_device_distribution
      ActiveRecord::Base.connection.execute(
        <<-DEV_DISTR
          select users.id, count(devices) dev_count
          from users
          join devices on devices.user_id = users.id
          group by users.id
        DEV_DISTR
      )
    end

    def active_device_distribution
      ActiveRecord::Base.connection.execute(
        <<-DEV_DISTR
          select ds.id, count(devices) dev_count
          from #{ItemsByMonthsQuery::ACTIVE_USERS_BY_MONTHS} ds
          join devices on devices.user_id = ds.id
          where EXTRACT(MONTH from ds.created_at) = EXTRACT(MONTH from now())
          group by ds.id
        DEV_DISTR
      )
    end
  end
end
