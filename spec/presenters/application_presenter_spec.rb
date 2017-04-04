require "rails_helper"

describe ApplicationPresenter do
  subject(:application_presenter) { described_class.new }

  describe "Interface" do
    it { is_expected.to respond_to :checkins_date_range }
  end

  describe "checkins_date_range" do
    before do
      allow(application_presenter).to receive(:params).and_return from: nil, to: nil
    end

    it "returns from to hash with nil values" do
      expect(application_presenter.checkins_date_range).to eq from: nil, to: nil
    end

    it "returns from beginning of day to end of day hash values" do
      allow(application_presenter).to receive(:params).and_return from: "2017-03-25", to: "2017-03-27"
      expect(application_presenter.checkins_date_range).to eq from: Date.parse("2017-03-25").beginning_of_day,
                                                              to: Date.parse("2017-03-27").end_of_day
    end
  end
end
