require 'rails_helper'

RSpec.describe Api::ApiController, type: :controller do
  
  before do
    @user = FactoryGirl::create :user
    @developer = FactoryGirl::create :developer
    request.headers["X-Api-Key"] = @developer.api_key
  end

end
