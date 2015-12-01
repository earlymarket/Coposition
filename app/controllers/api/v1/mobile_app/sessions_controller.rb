class Api::V1::MobileApp::SessionsController < Devise::SessionsController
  respond_to :json
end