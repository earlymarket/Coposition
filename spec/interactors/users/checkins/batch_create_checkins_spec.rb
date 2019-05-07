require "rails_helper"

RSpec.describe Users::Checkins::BatchCreateCheckins, type: :interactor do
  subject(:batch_context) { described_class.call(device: device, post_content: post_content) }

  let(:post_content) do
    [{ lat: "50.588330", lng: "-0.513069" }, { lat: "51.588330", lng: "-1.513069" }].to_json
  end
  let(:device) { create :device, user: user }
  let(:user) { create :user }

  describe "call" do
    context "when given valid post_content" do
      it "succeeds" do
        expect(batch_context).to be_a_success
      end

      it "creates new checkins" do
        expect(batch_context.checkins).to eq Checkin.all
      end
    end

    context "when given invalid post-content" do
      let(:batch_context) { described_class.call(device: device, post_content: [{ lat: "50.588330" }].to_json) }

      it "fails" do
        expect(batch_context).to be_a_failure
      end
    end
  end
end
