module ControllerMacros

  class << self
    def included(target)
      overwrite_actor_owns_resource
    end

    def overwrite_actor_owns_resource
      ApplicationController.class_eval do
        def actor_owns_resource?(actor, resource, id)
          resource = resource.titleize.constantize
          resource.find(id).send(actor) == User.last
        end
      end
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end

  def res_hash
    # Check if it's a different request
    @json = nil if response != @res

    @json ||= begin
      json = JSON(response.body)
      json = JSON(response.body).symbolize_keys unless JSON(response.body).is_a? Array
      @res = response.dup
      json
    end
  end

end