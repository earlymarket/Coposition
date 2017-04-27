class ActivitiesPresenter
  attr_reader :activities
  attr_reader :gon

  def initialize(params)
    @params = params
  end

  def activities
    if @params[:search]
      activities = find_user_activities
    else
      activities = filter_params ? PublicActivity::Activity.where(filter_params) : PublicActivity::Activity.all
    end
    activities.order("created_at desc").paginate(per_page: 15, page: @params[:page])
  end

  def gon
    { users: User.pluck(:email) }
  end

  private

  def filter_params
    return false unless @params[:filter]
    @params.require(:filter).permit(:trackable_type, :trackable_id, :owner_type, :owner_id, :key)
  end

  def find_user_activities
    user = User.find_by(email: @params[:owner_id])
    PublicActivity::Activity.where(owner_id: user.id, owner_type: "User")
  end
end
