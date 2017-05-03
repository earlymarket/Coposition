class CreateActivity
  include Interactor

  delegate :entity, :action, :activity, :owner, :params, to: :context

  def call
    entity.create_activity action, owner: owner, parameters: params
  end
end
