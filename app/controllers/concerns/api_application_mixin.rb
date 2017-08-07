module ApiApplicationMixin
  def method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s
    if /(?<resource>[\w]+)_exists\?$/ =~ method_string
      resource_exists?(resource, arguments[0])
    elsif params[:id] && /(?<actor>[\w]+)_owns_(?<res>[\w]+)\?$/ =~ method_string
      actor_owns_resource? actor, res, params[:id]
    else
      super
    end
  end

  def actor_owns_resource?(actor, resource, id)
    model = resource.titleize.constantize
    resource = model.find(id)
    owner = if model == Checkin || model == Permission && actor == 'user'
              resource.device.user
            else
              resource.send(actor)
            end
    owner == send("current_#{actor}")
  end

  def req_from_coposition_app?
    request.headers['X-Secret-App-Key'] == Rails.application.secrets.mobile_app_key
  end

  def approval_zapier_data(approval)
    [approval.user.public_info.as_json.merge(approval.as_json)]
  end

  def doorkeeper_unauthorized_render_options(*)
    { json: { error: "Not authorized" } }
  end
end
