class Developers::Devise::SessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(resource)
    developers_console_path
  end
end
