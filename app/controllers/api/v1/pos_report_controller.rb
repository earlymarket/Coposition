class Api::V1::PosReportController < Api::ApiController
  respond_to :json

  def create
    PosReport.create allowed_params
  end

  private

  def allowed_params
    params.require(:checkin).permit(:uuid, :lat, :lng)
  end

end