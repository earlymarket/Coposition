module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead", required: true }
    elsif type == "User"
      { placeholder: "email@email.com", class: "validate", required: true }
    end
  end

  def approvals_pending_friends(user)
    string = ''
    user.pending_friends.each_with_index do |friend, index|
      string += friend.email
      string += ', ' if index < user.pending_friends.length - 2
      string += ' and ' if index == user.pending_friends.length - 2
    end
    return string
  end
end
