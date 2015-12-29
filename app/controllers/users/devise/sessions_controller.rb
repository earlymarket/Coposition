class Users::Devise::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format.symbol == :json }
  respond_to :json

end
