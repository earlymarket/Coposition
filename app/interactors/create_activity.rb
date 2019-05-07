class CreateActivity
  include Interactor

  delegate :entity, :action, :owner, :params, to: :context

  def call
    entity.create_activity action, owner: owner, parameters: params
    check_count if Rails.env.staging?
  end

  def check_count
    return unless PublicActivity::Activity.count > 2000
    PublicActivity::Activity.destroy(PublicActivity::Activity.first(1000).pluck(:id))
  end
end
