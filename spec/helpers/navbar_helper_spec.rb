require "rails_helper"

RSpec.describe NavbarHelper, :type => :helper do

  describe '#navbar_indicator' do
    it 'should insert an indicator if given a count greater than 0' do
      expect { helper.navbar_indicator('blah', 1) }.not_to raise_error
      expect(helper.navbar_indicator('blah', 1)).to match('blah')
      expect(helper.navbar_indicator('blah', 1).length).to be > 'blah'.length
    end

    it 'should return the input string if count is 0' do
      expect { helper.navbar_indicator('blah', 0) }.not_to raise_error
      expect(helper.navbar_indicator('blah', 0)).to eq('blah')
    end
  end

end
