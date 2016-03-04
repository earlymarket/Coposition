module ApprovalsHelper

  def approvals_typeahead(type)
    if type == 'Developer'
      "validate devs_typeahead"
    elsif type == 'User'
      "validate users_typeahead"
    end
  end
end
