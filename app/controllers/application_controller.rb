class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s
    if params[:id] && method_string =~ /_owns_[\w]+\?$/
      owns_resource? method_string.split("_owns_"), params[:id]
    else
      super
    end
  end

  private

  def owns_resource?(array, id)
    # Called from method_missing
    # Usage: user_owns_device?
    # Checks whether resource belongs to actor

    @actor = array.first
    @resource = array.second.chomp("?").titleize.constantize
    item = @resource.find(id)
    item.send(@actor) == send("current_#{@actor}")
  end
end

  