class Developers::RequestsController < ApplicationController

  def pay
    balance = current_developer.requests.where(paid: false)
    balance.update_all(paid: true)
    redirect_to developers_console_path
  end
end
