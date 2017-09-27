module CustomTokenResponse
  def body
    additional_data = {
      "user" => User.find(token.resource_owner_id).public_info_hash
    }

    # call original `#body` method and merge its result with the additional data hash
    super.merge(additional_data)
  end
end
