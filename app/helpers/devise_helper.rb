module DeviseHelper
  def devise_error_messages!
    return "" unless devise_error_messages?
    flash[:errors] = resource.errors.full_messages
    nil
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

  def sign_up_registration_path(resource_name)
    resource_name === :user ? new_user_registration_path : new_developer_registration_path
  end

  private

  def resource
    @resource ||= User.new
  end
end
