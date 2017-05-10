require "rails_helper"

RSpec.describe DeviseHelper, type: :helper do
  let(:user) { create(:user) }

  describe "devise_error_messages!" do

    it "returns empty string if devise_error_messages don't exist" do
      expect(helper.devise_error_messages!).to eq ""
    end
  end
end
