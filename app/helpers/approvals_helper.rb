module ApprovalsHelper
  def approvals_input(type)
    if type == 'Developer'
      { placeholder: 'App name', class: 'validate devs_typeahead', required: true }
    elsif type == 'User'
      { placeholder: 'email@email.com', class: 'validate', required: true }
    end
  end

  def approvals_approvable_name(approvable)
    if approvable.respond_to? :username
      approvable.username.present? ? approvable.username : approvable.email.split('@').first
    else
      approvable.company_name
    end
  end

  def approvals_friends_device_link(approvable_type, approvable, &block)
    return capture(&block) unless approvable_type == 'User'
    str = '<a href="'
    str << Rails.application.routes.url_helpers.user_friend_path(current_user.url_id, approvable)
    str << '" class="black-text">'
    str << capture(&block)
    str << '</a>'
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

  def create_approval_url(type)
    if type == 'Developer'
      Rails.application.routes.url_helpers.user_create_dev_approvals_path(current_user.url_id)
    elsif type == 'User'
      Rails.application.routes.url_helpers.user_approvals_path(current_user.url_id)
    end
  end
end
