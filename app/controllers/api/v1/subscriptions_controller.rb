class Api::V1::SubscriptionsController < ActionController::API
  def create
    sub = subscriber.subscriptions.create(allowed_params)
    render status: 201, json: { id: sub.id }
  end

  def destroy
    sub = subscriber.subscriptions.destroy(params[:id]).first
    render status: 200, json: { id: sub.id }
  end

  private

  def allowed_params
    params.permit(:target_url, :event)
  end

  def subscriber
    key = request.headers['X-Authentication-Key']
    User.find_by(webhook_key: key) || Developer.find_by(api_key: key)
  end
end
