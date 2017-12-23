class Users::EmailRequestsController < ApplicationController
  before_action :authenticate_user!, except: :add
  before_action :correct_url_user?, except: :add

  def destroy
    EmailRequest.find(params[:id]).destroy
    approvals_presenter_and_gon(approvable_type: "User")
    render "users/approvals/update"
  end
end
