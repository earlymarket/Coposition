ActiveAdmin.register_page "Device Distribution" do
  DEVICE_NUMBERS = [0, 1, 2, 3, 4, 5]
  DISTRIBUTION_TYPES = %i(full active).freeze
  DEVICE_DISTRIBUTION_HEADERS = %w[Devices Consumers Percent]

  menu parent: "Reports"

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
      build_collection(full_device_distribution, User.active_users.count)
    end

    def active_distribution
      total = ActiveRecord::Base.connection.execute(
        "select distinct ds.id \
        from #{ItemsByMonthsQuery::ACTIVE_USERS_BY_MONTHS} ds \
        where EXTRACT(MONTH from ds.created_at) = EXTRACT(MONTH from now())"
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
        percent: total.zero? ? "n/a" : "%.2f %" % (distr.to_f * 100 / total)
      }
    end

    def full_device_distribution
      ActiveRecord::Base.connection.execute(
        <<-DEV_DISTR
          select users.id, count(devices) dev_count
          from users
          left join devices on devices.user_id = users.id
          where (users.is_active = true)
          group by users.id
        DEV_DISTR
      )
    end

    def active_device_distribution
      ActiveRecord::Base.connection.execute(
        <<-DEV_DISTR
          select ds.id, count(devices) dev_count
          from #{ItemsByMonthsQuery::ACTIVE_USERS_BY_MONTHS} ds
          left join devices on devices.user_id = ds.id
          where EXTRACT(MONTH from ds.created_at) = EXTRACT(MONTH from now())
          group by ds.id
        DEV_DISTR
      )
    end
  end

  page_action :full_csv, method: :get do
    collection = full_distribution

    csv = CSV.generate(encoding: "UTF-8") do |csv|
      # add headers
      csv << HEADERS
      collection.each do |item|
        csv << [item[:devices], item[:consumers], item[:percent]]
      end
    end
    # send file to user
    send_data csv.encode("UTF-8"),
      type: "text/csv; charset=windows-1251; header=present",
      disposition: "attachment; filename=full_device_distribution_#{DateTime.now.to_s}.csv"
  end

  page_action :active_csv, method: :get do
    collection = active_distribution

    csv = CSV.generate(encoding: "UTF-8") do |csv|
      # add headers
      csv << HEADERS
      collection.each do |item|
        csv << [item[:devices], item[:consumers], item[:percent]]
      end
    end
    # send file to user
    send_data csv.encode("UTF-8"),
      type: "text/csv; charset=windows-1251; header=present",
      disposition: "attachment; filename=active_device_distribution_#{DateTime.now.to_s}.csv"
  end

  action_item :full_csv do
    link_to "All to CSV", admin_device_distribution_full_csv_path, method: :get
  end

  action_item :active_csv do
    link_to "Active to CSV", admin_device_distribution_active_csv_path, method: :get
  end
end
