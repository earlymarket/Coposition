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

  protected

    def actor_owns_resource?(actor, resource, id)
      # Called from method_missing
      # Usage: user_owns_device?
      # Checks whether resource belongs to actor

      resource = resource.titleize.constantize
      item = resource.find(id)
      item.send(actor) == send("current_#{actor}")
    end
end