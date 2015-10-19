require 'rails_helper'

RSpec.describe Request, type: :model do

  describe "relationships" do
    before do
      @dev = FactoryGirl::create :developer
      @req = FactoryGirl::create :request
      @req.developer = @dev
      @req.save
    end

    it "should have a developer" do
      expect(@req.developer).to eq @dev
    end
  end 

end