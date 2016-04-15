module DeviseHelper
  def devise_error_messages!
    return "" unless devise_error_messages?
    flash[:errors] = resource.errors.full_messages
    return nil
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

end
