module RequestsHelper
  def requests_user(request)
    request.user_id ? User.find_by(id: request.user_id).username : "n/a"
  end
end
