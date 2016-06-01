require 'rails_helper'

RSpec.describe NavbarHelper, type: :helper do
  let(:random_word) { Faker::Lorem.word }
  let(:random_count) { Faker::Number.between(1, 99) }

  describe '#navbar_indicator' do
    it 'should insert an indicator if given a count greater than 0' do
      expect { helper.navbar_indicator(random_word, random_count) }.not_to raise_error
      expect(helper.navbar_indicator(random_word, random_count)).to match(random_word)
      expect(helper.navbar_indicator(random_word, random_count).length).to be > random_word.length
    end

    it 'should return the input string if count is 0' do
      expect { helper.navbar_indicator(random_word, 0) }.not_to raise_error
      expect(helper.navbar_indicator(random_word, 0)).to eq(random_word)
    end
  end
end
