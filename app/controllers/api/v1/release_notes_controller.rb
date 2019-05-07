class Api::V1::ReleaseNotesController < Api::ApiController
  skip_before_action :find_user, :update_last_mobile_visit_at

  def index
    note = ReleaseNote.where(application: params[:application], version: params[:version])
    render json: note if req_from_coposition_app?
  end
end
