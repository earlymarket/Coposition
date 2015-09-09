class ConnectionsController < ApplicationController

  def index
    @connection_code = current_user.connection_code
  end

end
