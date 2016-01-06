class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s
    if params[:id] && /(?<actor>[\w]+)_owns_(?<resource>[\w]+)\?$/ =~ method_string
      actor_owns_resource? actor, resource, params[:id]
    else
      super
    end
  end

  def req_from_coposition_app?
    @from_copo_app ||= request.headers["X-Secret-App-Key"] == Rails.application.secrets.mobile_app_key
  end

  def invalid_payload(msg, redirect_path)
    if req_from_coposition_app?
      render status: 400, json: { message: msg }
    else
      flash[:alert] = msg
      redirect_to redirect_path
    end
  end


  protected

    def actor_owns_resource?(actor, resource, id)
      # Called from method_missing
      # Usage: user_owns_device?
      # Checks whether resource belongs to actor
      # Overwritten by ControllerMacros in tests (when included)

      model = resource.titleize.constantize
      resource = model.find(id)
      if (model == Checkin && actor == 'user')
        owner = resource.device.user
      else
        owner = resource.send(actor)
      end
      owner == send("current_#{actor}")
    end

end