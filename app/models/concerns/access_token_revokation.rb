module AccessTokenRevokation
  extend ActiveSupport::Concern

  included do
    after_create :revoke_others
  end

  private

  def revoke_others
    self.class
      .where(
        application_id: application_id,
        resource_owner_id: resource_owner_id,
        revoked_at: nil
      )
      .where.not(id: id)
      .each(&:revoke)
  end
end
