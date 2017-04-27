class ActivitiesController < ApplicationController
  before_action :authenticate_admin!

  def index
    gon.push(users: User.pluck(:email))
    if params[:search]
      user = User.find_by(email: params[:owner_id])
      activities = PublicActivity::Activity.where(owner_id: user.id, owner_type: "User")
    else
      activities = filter_params ? PublicActivity::Activity.where(filter_params) : PublicActivity::Activity.all
    end
    @activities = activities.order("created_at desc").paginate(per_page: 15, page: params[:page])
  end

  private

  def filter_params
    return false unless params[:filter]
    params.require(:filter).permit(:trackable_type, :trackable_id, :owner_type, :owner_id, :key)
  end
end
