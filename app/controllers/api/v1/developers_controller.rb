class Api::V1::DevelopersController < Api::ApiController
  respond_to :json

  skip_before_action :find_user, :update_last_mobile_visit_at

  def index
    respond_with Developer.all.select(:id, :company_name, :email)
  end

  def show
    respond_with Developer.find(params[:id]).public_info
  end
end
