class Api::V1::ConfigsController < Api::ApiController
  respond_to :json

  skip_before_action :find_user, :update_last_mobile_visit_at

  def index
    render json: @dev.configs
  end

  def show
    render json: configuration
  end

  def update
    configuration.update(custom: custom_params)
    CreateActivity.call(entity: configuration,
                        action: :update,
                        owner: configuration.device.user,
                        params: custom_params.to_h)
    render json: configuration
  end

  private

  def custom_params
    params.require(:config).permit![:custom].as_json
  end

  def configuration
    if req_from_coposition_app?
      Config.find(params[:id])
    else
      @dev.configs.find(params[:id])
    end
  end
end
