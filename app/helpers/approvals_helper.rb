module ApprovalsHelper

  def approvals_input(type)
    if type == "Developer"
      { placeholder: "App name", class: "validate devs_typeahead", required: true }
    elsif type == "User"
      { placeholder: "email@email.com", class: "validate", required: true }
    end
  end
end
