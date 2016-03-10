module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead", required: true }
    elsif type == "User"
      { placeholder: "Username (email if inviting)", class: "validate users_typeahead", required: true }
    end
  end
end
