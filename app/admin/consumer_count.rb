ActiveAdmin.register_page "Consumer Count" do
  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:collection] = ItemsByMonthsQuery.new(table: "users").all
    end
  end
end
