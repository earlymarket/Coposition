require 'rails_helper'

RSpec.describe Request, type: :model do

  let(:developer) { FactoryGirl::create(:developer) }
  let(:request) do
    req = FactoryGirl::create :request
    req.developer = developer
    req
  end

  describe "relationships" do

    it "should have a developer" do
      expect(request.developer).to eq developer
    end
  end 

end