class ActivitiesPresenter
  attr_reader :activities
  attr_reader :gon

  def initialize(params)
    @params = params
  end

  def activities
    activities = if @params[:search]
      filter_trackable_types.present? ? load_activities.where(trackable_type: filter_trackable_types) : load_activities
    else
      filter_params ? PublicActivity::Activity.where(filter_params) : PublicActivity::Activity.all
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

  def load_activities
    return PublicActivity::Activity.all unless (user = User.find_by(email: @params[:owner_id]))
    PublicActivity::Activity.all.where(owner_id: user.id, owner_type: "User")
  end

  def filter_trackable_types
    @params.select { |_param, value| value == "true" }.keys.select { |key| trackable_types.include? key }
  end

  def trackable_types
    %w(Device Config Approval Permission)
  end
end
