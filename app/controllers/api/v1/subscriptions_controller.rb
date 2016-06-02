class Api::V1::SubscriptionsController < ActionController::Base
  def create
    subscriber = User.find_by(webhook_key: request.headers['X-Authentication-Key'])
    subscriber ||= Developer.find_by(api_key: request.headers['X-Authentication-Key'])
    sub = subscriber.subscriptions.create(allowed_params)
    render status: 201, json: { id: sub.id }
  end

  def destroy
    key = request.headers['X-Authentication-Key']
    subscriber = User.find_by(webhook_key: key)
    subscriber ||= Developer.find_by(api_key: key)
    sub = subscriber.subscriptions.destroy(params[:id]).first
    render status: 200, json: { id: sub.id }
  end

  private

  def allowed_params
    params.permit(:target_url, :event)
  end
end
