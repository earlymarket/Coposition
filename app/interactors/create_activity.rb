class CreateActivity
  include Interactor

  delegate :entity, :action, :owner, :params, to: :context

  def call
    entity.create_activity action, owner: owner, parameters: params
  end
end
