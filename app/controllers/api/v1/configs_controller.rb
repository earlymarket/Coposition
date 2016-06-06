class Api::V1::ConfigsController < Api::ApiController
  respond_to :json

  skip_before_action :find_user

  def index
    render json: @dev.configs
  end

  def show
    config = @dev.configs.find_by(device_id: params[:id])
    render json: config
  end

  def update
    config = @dev.configs.find_by(device_id: params[:id])
    return unless config_exists? config
    config.update(custom: custom_params)
    render json: config
  end

  private

  def custom_params
    params[:config][:custom]
  end
end
