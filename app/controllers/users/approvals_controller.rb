class Users::ApprovalsController < ApplicationController
  before_action :authenticate_user!, except: :add
  before_action :correct_url_user?, except: :add

  def new
    @approvals_presenter = Users::ApprovalsPresenter.new(current_user, params)
    @approval = Approval.new
    gon.push(devs: (Developer.all - current_user.developers).pluck(:company_name))
  end

  def add
    if current_user
      redirect_to(new_user_approval_path(current_user, approvable_type: "User", email: params["email"]))
    else
      redirect_to(new_user_session_url(return_to: request.fullpath))
    end
  end

  def create
    result = Users::Approvals::CreateUserApproval.call(
      current_user: current_user,
      approvable: approval_params[:approvable]
    )
    approvals_presenter_and_gon(approvable_type: "User") if result.success?
    redirect_to(result.path, result.message)
  end

  def index
    approvals_presenter_and_gon(params)
    render "approvals"
  end

  def update
    result = Users::Approvals::UpdateApproval.call(
      current_user: current_user,
      params: params
    )
    if result.approvable_type == "Developer"
      result.approvable.notify_if_subscribed("new_approval", approval_zapier_data(result.approval))
    end
    approvals_presenter_and_gon(approvable_type: result.approvable_type)
  end

  def destroy
    result = Users::Approvals::DestroyApproval.call(
      current_user: current_user,
      params: params
    )
    approvals_presenter_and_gon(approvable_type: result.approvable_type)
    render "update"
  end

  private

  def approval_params
    params
      .require(:approval)
      .permit(:approvable, :approvable_type)
  end
end
