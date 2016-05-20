class Api::V1::SubscriptionsController < ActionController::Base

  def create
    user = User.find_by(email: params[:email])
    sub = user.subscriptions.create(allowed_params)
    render status: 201, json: sub.id
  end

  def destroy
    user = User.find_by(email: params[:email])
    sub = user.subscriptions.find(params[:id]).destroy
    render status: 200, json: sub.id
  end

  private

    def allowed_params
      params.permit(:target_url, :event)
    end
end

