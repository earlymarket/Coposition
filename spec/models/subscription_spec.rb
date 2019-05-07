require "rails_helper"

RSpec.describe Subscription, type: :model do
  let(:developer) { create(:developer) }
  let(:subscription) { create(:subscription) }

  describe "factory" do
    it "creates a valid subscription" do
      sub = build(:subscription)
      expect(sub).to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a user or developer" do
      assc = described_class.reflect_on_association(:subscriber)
      expect(assc.macro).to eq :belongs_to
    end
  end

  describe "public instance methods" do
    context "responds to its method" do
      it { expect(subscription).to respond_to(:send_data) }
      it { expect(subscription).to respond_to(:check_response) }
    end

    context "send_data" do
      before do
        stub_request(:post, "https://zapier.com").to_return(status: 200, body: "OK", headers: {})
      end

      it "makes zapier network request" do
        subscription.send_data("data")
        assert_requested :post, "https://zapier.com"
      end

      it "calls check_response" do
        allow(subscription).to receive :check_response
        subscription.send_data("data")
        expect(subscription).to have_received :check_response
      end
    end

    context "check_response" do
      def make_request(uri)
        uri = URI.parse(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(subscription.target_url)
        request.add_field("Content-Type", "application/json")
        request.body = "\"data\""
        http.request(request)
      end

      let(:success) do
        stub_request(:post, "https://zapier.com").to_return(status: 200, body: "OK", headers: {})
        make_request("https://zapier.com/")
      end
      let(:invalid) do
        stub_request(:post, "https://zapier.com").to_return(status: 400, body: "Invalid request", headers: {})
        make_request("https://zapier.com")
      end
      let(:destroy) do
        stub_request(:post, "https://zapier.com").to_return(status: 410, body: "delete response", headers: {})
        make_request("https://zapier.com")
      end

      it "returns nothing if request is a success" do
        expect(subscription.check_response(success)).to eq nil
      end

      it "prints response if request is invalid" do
        allow(STDOUT).to receive(:puts).with(invalid)
        subscription.check_response(invalid)
        expect(STDOUT).to have_received(:puts).with(invalid)
      end

      it "deletes subscription if request returns 410" do
        subscription.check_response(destroy)
        expect { Subscription.find(subscription.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
