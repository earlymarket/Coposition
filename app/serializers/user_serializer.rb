class UserSerializer < ActiveModel::Serializer
  def attributes(*args)
    hh = attribute_list
      .inject({}) do |h, key|
        h[key] = object.attributes[key.to_s]
        h
      end
      .tap do |h|
        h[:copo_app_access_token] = object.copo_app_access_token if object.private_profile
      end
  end

  private

  def attribute_list
    object.private_profile ? object.attribute_names.map(&:to_sym) : User::PUBLIC_ATTRIBUTES
  end
end
