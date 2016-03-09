class Developers::ConsolesController < ApplicationController
  before_action :authenticate_developer!

  def show
    @requests_today = current_developer.requests.recent(1.day.ago).count
    @unpaid = current_developer.requests.where(paid: false).count

    respond_to do |format|
      format.html
      format.js
    end
  end

end
