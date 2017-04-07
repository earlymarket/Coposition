class Users::UsersController < ApplicationController
  def show
    redirect_to action: 'show', controller: 'users/dashboards', user_id: params[:id]
  end

  def me
    token = Doorkeeper::AccessToken.find_by(
      token: request.headers["HTTP_AUTHORIZATION"].scan(/Bearer (.*)$/).flatten.last
    )

    render status: 200, json: User.find(token.resource_owner_id).public_info_hash
  end
end
