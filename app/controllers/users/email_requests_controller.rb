class Users::EmailRequestsController < ApplicationController
  def destroy
    EmailRequest.find(params[:id]).destroy
    approvals_presenter_and_gon(approvable_type: "User")
    render "users/approvals/update"
  end
end
