require 'rails_helper'

RSpec.describe User, type: :model do
  describe "relationships" do
    it "should have some devices" do
      @user = User.create
      @device = Device.create
      @user.devices << @device
      expect(@user.devices.last).to eq @device 
    end
  end
end
