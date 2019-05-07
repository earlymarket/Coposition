class Developers::ConsolesController < ApplicationController
  before_action :authenticate_developer!

  def show
    @requests_today = current_developer.requests.since(1.day.ago).count
    @unpaid = current_developer.requests.where(paid: false).count

    respond_to do |format|
      format.html
      format.js
    end
  end

  def key
    @api_key = SecureRandom.uuid
    current_developer.update(api_key: @api_key)
  end
end
