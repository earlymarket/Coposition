class Api::V1::SubscriptionsController < ActionController::Base

  def create
    # will receive url, event, user/dev
    # when event takes place, checks if user/dev has subscription (so has event+url attached to their account)
    # if they do, posts the data from this event to the url
    user = User.find_by(email: params[:email])
    sub = user.subscriptions.create(allowed_params)
    render json: sub.id
  end

  def destroy
  end

  private

    def allowed_params
      params.require(:target_url, :event)
    end
end

