# app/controllers/oauth/applications_controller.rb
class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_action :authenticate_developer!, except: :index
  before_action :authenticate_admin!, only: :index

  def show
    @application = current_developer.oauth_application
  end

  # only needed if each application must have some owner
  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_developer if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  private

  def set_application
    @application = current_developer.oauth_application
  end
end
