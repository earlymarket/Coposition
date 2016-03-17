module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead", required: true }
    elsif type == "User"
      { placeholder: "email@email.com", class: "validate", required: true }
    end
  end

  def friend_or_app_name(entity)
    if entity.respond_to? :username
      friend = entity
      friend.username.present? ? friend.username : friend.email.split("@").first
    else
      dev = entity
      dev.company_name
    end
  end

  def tagline_text(entity)
    if entity.respond_to? :tagline
      if entity.tagline then "<div>#{entity.tagline}</div>".html_safe end
    end
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
