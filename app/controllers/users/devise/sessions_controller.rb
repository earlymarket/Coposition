class Users::Devise::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session, :unless => :req_from_coposition_app?
  respond_to :json

end
