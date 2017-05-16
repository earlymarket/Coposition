ActiveAdmin.register_page "Checkin Count" do
  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:collection] = ItemsByMonthsQuery.new(table: "checkins").all
    end
  end
end
