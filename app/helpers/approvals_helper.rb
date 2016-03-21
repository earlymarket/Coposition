module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead", required: true }
    elsif type == "User"
      { placeholder: "email@email.com", class: "validate", required: true }
    end
  end

  def approvals_approvable_name(approvable)
    if approvable.respond_to? :username
      friend = approvable
      friend.username.present? ? friend.username : friend.email.split("@").first
    else
      dev = approvable
      dev.company_name
    end
  end

  def approvals_tagline_text(approvable)
    if approvable.respond_to? :tagline
      if approvable.tagline then approvable.tagline end
    end
  end

  def approvals_friends_device_link(approval_type, approvable, &block)
    return capture(&block) unless approval_type == 'User'
    str = '<a href="'
    str << user_friend_path(current_user.url_id, approvable)
    str << '" class="black-text">'
    str << capture(&block)
    str << "</a>"
    raw str
  end

  def approvals_pending_friends(user)
    string = ''
    user.pending_friends.each_with_index do |friend, index|
      string += friend.email
      string += ', ' if index < user.pending_friends.length - 2
      string += ' and ' if index == user.pending_friends.length - 2
    end
    string
  end
end
