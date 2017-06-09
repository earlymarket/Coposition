class ActivitiesPresenter
  attr_reader :activities
  attr_reader :gon

  TRACKABLE_TYPES = %w(Device Config Approval Permission).freeze

  def initialize(params)
    @params = params
  end

  def activities
    activities = if @params[:search]
      filter_trackable_types.present? ? load_activities.where(trackable_type: filter_trackable_types) : load_activities
    else
      filter_params || PublicActivity::Activity.all
    end
    activities.order("created_at desc").paginate(per_page: 15, page: @params[:page])
  end

  def gon
    { users: User.pluck(:email) }
  end

  private

  def filter_params
    return false unless @params["filter"]
    return PublicActivity::Activity.where(key: @params["key"]) if @params["key"]
    return PublicActivity::Activity.where(owner_id: @params["owner_id"], owner_type: @params["owner_type"]) if @params["owner_type"]
    PublicActivity::Activity.where(trackable_type: @params["trackable_type"], trackable_id: @params["trackable_id"])
  end

  def load_activities
    return PublicActivity::Activity.all unless (user = User.find_by(email: @params[:owner_id]))
    PublicActivity::Activity.all.where(owner_id: user.id, owner_type: "User")
  end

  def filter_trackable_types
    @params.keys.select { |key| TRACKABLE_TYPES.include?(key) && @params[key] == "true" }
  end
end
