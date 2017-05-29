ActiveAdmin.register_page "Active User Count" do
  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:collection] = ItemsByMonthsQuery.new(table: nil, active_users: true).all
    end
  end
end
