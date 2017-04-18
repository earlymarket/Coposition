module ApprovalsHelper
  def approvals_approvable_name(approvable)
    approvable.class == User ? approvable.display_name : approvable.company_name
  end

  def approvals_friends_device_link(approvable_type, approvable, &block)
    return capture(&block) unless approvable_type == "User"
    str = '<a href="'
    str << Rails.application.routes.url_helpers.user_friend_path(current_user.url_id, approvable)
    str << '" class="black-text">'
    str << capture(&block)
    str << "</a>"
    raw str
  end

  def approvals_friends_locator(approvable_type, approvable)
    return unless approvable_type == "User"
    "<i data-friend='#{approvable.id}' class='center-map material-icons'>my_location</i>".html_safe
  end
end
