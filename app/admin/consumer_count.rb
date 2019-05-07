ActiveAdmin.register_page "Monthly new users" do
  CONSUMER_COUNT_HEADERS = %w[Month Total Growth]

  menu parent: "Reports"

  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:collection] = ItemsByMonthsQuery.new(users: true).all
    end
  end

  page_action :csv, method: :get do
    collection = ItemsByMonthsQuery.new(users: true).all

    csv = CSV.generate(encoding: "UTF-8") do |csv|
      # add headers
      csv << HEADERS
      collection.each do |item|
        csv << [item["month"], item["total"], "%.2f %" % item["growth"].to_f]
      end
    end
    # send file to user
    send_data csv.encode("UTF-8"),
      type: "text/csv; charset=windows-1251; header=present",
      disposition: "attachment; filename=users_#{DateTime.now.to_s}.csv"
  end

  action_item :csv do
    link_to "Export to CSV", admin_monthly_new_users_csv_path, method: :get
  end
end
