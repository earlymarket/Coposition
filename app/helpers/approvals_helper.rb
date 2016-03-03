module ApprovalsHelper

  def approvals_typeahead(type)
    if type == 'Developer'
      "validate devs_typeahead"
    else
      "validate users_typeahead"
    end
  end
end
