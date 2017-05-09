require 'rails_helper'

RSpec.describe Api::V1::Users::LocationsController, type: :controller do
  include ControllerMacros

  before do
    api_request_headers(developer, user)
  end
end
