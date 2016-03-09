require "rails_helper"

RSpec.describe DevicesHelper, :type => :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:user) { FactoryGirl::create(:user) }
  let(:developer) { FactoryGirl::create(:developer) }

  describe '#permissible_title' do
    it 'should accept either a user or a developer' do
      expect { helper.permissible_title(user) }.not_to raise_error
      expect { helper.permissible_title(developer) }.not_to raise_error
    end

    it "should return html with the user's email if it's a user" do
      expect( helper.permissible_title(user) ).to match(user.email)
      expect( helper.permissible_title(user).class ).to eq(safebuffer)
    end

    it "should return html with the company name if it's a developer" do
      expect( helper.permissible_title(developer).class ).to eq(safebuffer)
      expect( helper.permissible_title(developer) ).to match(ERB::Util::h(developer.company_name))
    end

  end

end
