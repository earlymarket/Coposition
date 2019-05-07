require "rails_helper"

RSpec.describe DashboardHelper, type: :helper do
  describe "#dashboard_country_name" do
    it "turns 'gb' to 'United Kingdom' regardless of case" do
      examples = %w(gb gB Gb GB)
      examples.each { |e| expect(helper.dashboard_country_name(e)).to eq "United Kingdom of Great Britain and Northern Ireland" }
    end

    it "returns unknown codes" do
      expect(helper.dashboard_country_name("NO CODE")).to eq "NO CODE"
    end
  end

  describe "#dashboard_flag" do
    it "should return a placeholder if we don't have a flag" do
      expect(helper.dashboard_flag("GL")).to match "noflag.png"
    end

    it "returns a placeholder when we don't know the country code" do
      expect(helper.dashboard_flag("ABCD")).to match "noflag.png"
    end

    it "returns a flag if we know the country and have it's flag" do
      expect(helper.dashboard_flag("GB")).to match "gb.png"
    end
  end
end
