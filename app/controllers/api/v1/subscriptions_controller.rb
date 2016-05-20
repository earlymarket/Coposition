class Api::V1::SubscriptionsController < ActionController::Base

  def create
    token = request.headers['X-Zapier-Token']
    user = User.find_by(authentication_token: token)
    sub = user.subscriptions.create(allowed_params)
    render status: 201, json: sub.id
  end

  def destroy
    token = request.headers['X-Zapier-Token']
    user = User.find_by(authentication_token: token)
    sub = user.subscriptions.find(params[:id]).destroy
    render status: 200, json: sub.id
  end

  private

    def allowed_params
      params.permit(:target_url, :event)
    end
end

