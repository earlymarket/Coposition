ActiveAdmin.register_page "Device Settings" do
  BOOLEAN_HEADERS = %w(On Off)

  content do
    render "index", layout: "active_admin"
  end

  controller do
    def index
      params[:fogged] = fogged_stats
      params[:cloaked] = cloaked_stats
    end

    private

    def fogged_stats
      {
        on: (num = Device.where(fogged: true).count * 100 / Device.count),
        off: (100 - num)
      }
    end

    def cloaked_stats
      {
        on: (num = Device.where(cloaked: true).count * 100 / Device.count),
        off: (100 - num)
      }
    end
  end
end
