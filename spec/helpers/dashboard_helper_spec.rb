require 'rails_helper'

RSpec.describe DashboardHelper, :type => :helper do

  describe '#dashboard_country_name' do
    it "should turn 'gb' to 'United Kingdom'" do
      expect(helper.dashboard_country_name('gb')).to eq 'United Kingdom'
    end

    it "should turn 'GB' to 'United Kingdom'" do
      expect(helper.dashboard_country_name('GB')).to eq 'United Kingdom'
    end

    it "should turn 'NO CODE' to 'NO CODE' " do
      expect(helper.dashboard_country_name('NO CODE')).to eq 'NO CODE'
    end
  end

  describe '#dashboard_flag' do
    it "should return a placeholder if it can't find the country code" do
      expect(helper.dashboard_flag('NO CODE')).to match 'noflag.png'
    end

    it "should return a placeholder if we don't have the flag but we do have the country code" do
      expect(helper.dashboard_flag('GL')).to match 'noflag.png'
    end

    it 'should return a flag if we know the country' do
      expect(helper.dashboard_flag('GB')).to match 'gb.png'
    end
  end

  describe '#dashboard_visited_countries_title' do
    it 'should correctly pluralize based on the number of visited countries' do
      expect(helper.dashboard_visited_countries_title(1)).to match 'Last Country'
      expect(helper.dashboard_visited_countries_title(0)).to match 'No Countries'
      expect(helper.dashboard_visited_countries_title(11)).to match 'Countries Visited'
    end
  end

end
