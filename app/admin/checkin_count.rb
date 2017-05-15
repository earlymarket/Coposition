ActiveAdmin.register_page "Checkin Count", namespace: :growth do
  content do
    redirect_to :index
  end

  page_action :index do
    @collection = ItemsByMonthsQuery.new(table: "checkins").all
    render :index, layout: 'active_admin'
  end

  # controller do
  #   def scoped_collection
  #     ItemsByMonthsQuery.new(table: "checkins").all
  #   end
  # end

  # index pagination_total: false do
  #   column :month, sortable: false do |item|
  #     item["month"]
  #   end
  #   column :total, sortable: false do |item|
  #     item["total"]
  #   end
  #   column :growth, sortable: false do |item|
  #     item["growth"]
  #   end
  # end
end
