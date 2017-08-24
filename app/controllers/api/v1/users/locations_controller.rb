class Api::V1::Users::LocationsController < Api::ApiController
  respond_to :json

  before_action :check_user_approved_approvable, :find_device

  MAX_PER_PAGE = 1000

  def index
    locations = @user.filtered_locations(filter_arguments)
    paginated_response_headers(locations)

    respond_with locations: locations
  end

  private

  def per_page
    params[:per_page].to_i <= MAX_PER_PAGE ? params[:per_page] : MAX_PER_PAGE
  end

  def find_device
    @device = Device.find(params[:device_id]) if params[:device_id]
  end

  def filter_arguments
    {
      copo_app: req_from_coposition_app?,
      permissible: @permissible,
      device: @device,
      page: params[:page],
      per_page: per_page,
      type: params[:type],
      near: params[:near]
    }
  end
end
