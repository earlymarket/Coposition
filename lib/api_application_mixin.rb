module ApiApplicationMixin

  def method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s
    if /(?<resource>[\w]+)_exists\?$/ =~ method_string
      resource_exists?(resource, arguments[0])
    elsif params[:id] && /(?<actor>[\w]+)_owns_(?<resource>[\w]+)\?$/ =~ method_string
      actor_owns_resource? actor, resource, params[:id]
    else
      super
    end
  end

  def resource_exists?(resource, arguments)
    model = resource.titleize.constantize
    render status: 404, json: { message: "#{model} does not exist" } unless arguments
    arguments
  end

  def actor_owns_resource?(actor, resource, id)
    # Called from method_missing
    # Usage: user_owns_device?
    # Checks whether resource belongs to actor
    model = resource.titleize.constantize
    resource = model.find(id)
    if (model == Checkin || model == Permission && actor == 'user')
      owner = resource.device.user
    else
      owner = resource.send(actor)
    end
    owner == send("current_#{actor}")
  end

  def req_from_coposition_app?
    @from_copo_app ||= request.headers["X-Secret-App-Key"] == Rails.application.secrets.mobile_app_key
  end

  def model_find(type)
    [User, Developer].find { |model| model.name == type.titleize}
  end
end