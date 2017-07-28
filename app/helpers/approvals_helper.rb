module ApprovalsHelper
  def approvals_approvable_name(approvable)
    approvable.class == User ? approvable.display_name : approvable.company_name
  end

  def approvals_add_text(type)
    type == "User" ? "Add new friend" : "Connect new app"
  end

  def approvals_new_text(type)
    if type == "User"
      "<p>Enter the email of the friend you would like to add</p>".html_safe
    else
      "<p>Enter the App you would like to connect to.</p>
      <p>Your data will not be accessible until you complete the authentication process.</p>".html_safe
    end
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
