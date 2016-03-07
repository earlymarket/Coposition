module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead" }
    elsif type == "User"
      { placeholder: "email@email.com", class: "validate users_typeahead" }
    end
  end
end
