module RequestsHelper
  def requests_user(request)
    User.find_by(id: request.user_id).username if request.user_id
  end
end
