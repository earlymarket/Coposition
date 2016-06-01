class Developers::RequestsController < ApplicationController
  def pay
    unpaid = current_developer.requests.where(paid: false)
    unpaid.update_all(paid: true)

    respond_to do |format|
      format.html { redirect_to developers_console_path }
      format.js
    end
  end
end
