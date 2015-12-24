class Users::Devise::SessionsController < Devise::SessionsController

  respond_to :json

  protect_from_forgery with: :null_session

end
