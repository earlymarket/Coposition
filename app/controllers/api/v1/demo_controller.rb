class Api::V1::DemoController < Api::ApiController
  respond_to :json

  before_action :authenticate

  def reset_approvals
  	Approval.destroy(Approval.where(user: 1, developer: 1).first)
    render nothing: true
  end

  def demo_user_approves_demo_dev
  	User.find(1).approve_developer(1)
    render nothing: true
  end

end
