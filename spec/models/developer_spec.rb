require "rails_helper"

RSpec.describe Developer, type: :model do
  let(:user) { create(:user) }
  let(:developer) { create(:developer) }

  describe "factory" do
    it "creates a valid developer" do
      expect(developer).to be_valid
    end
  end

  describe "Associations" do
    %w(requests permissions devices subscriptions approvals pending_requests
       users configs configurable_devices).each do |asoc|
      it "has many #{asoc}" do
        assc = described_class.reflect_on_association(asoc.to_sym)
        expect(assc.macro).to eq :has_many
      end
    end
  end

  describe "callbacks" do
    let(:new_developer) { FactoryGirl.build(:developer) }
    context "before_create" do
      it "generates an api key" do
        expect { new_developer.save }.to change { new_developer.api_key }
      end
    end

    context "after_create" do
      it "generates new oauth application" do
        expect { new_developer.save }.to change { Doorkeeper::Application.count }.by 1
      end
    end
  end

  describe "public instance methods" do
    context "responds to its methods" do
      %i(slack_message public_info subscribed_to notify_if_subscribed configures_device?).each do |method|
        it { expect(developer).to respond_to(method) }
      end
    end

    context "slack_message" do
      it "generates a message for slack" do
        msg = "A new developer registered, id: #{developer.id}, "\
              "company_name: #{developer.company_name}, there are now #{Developer.count} developers."
        expect(developer.slack_message).to eq msg
      end
    end

    context "public_info" do
      it "returns a developer" do
        expect(developer.public_info).to be_kind_of(Developer)
      end

      it "returns devices public info" do
        expect(developer.public_info).not_to respond_to(:api_key)
      end
    end

    context "subscribed_to" do
      it "returns subscription if developer is subscribed to event" do
        create(:subscription, subscriber: developer)
        expect(developer.subscribed_to("new_checkin")).to be_kind_of Subscription
      end

      it "returns nothing if developer is not subscribed to event" do
        expect(developer.subscribed_to("new_checkin")).to eq nil
      end
    end

    context "notify_if_subscribed" do
      it "returns nothing if developer has not enabled zapier" do
        expect(developer.notify_if_subscribed("new_checkin", user)).to eq nil
      end

      it "returns nothing if developer is not subscribed" do
        developer.update(zapier_enabled: true)
        expect(developer.notify_if_subscribed("new_checkin", user)).to eq nil
      end

      it "calls send_data on subscription" do
        developer.update(zapier_enabled: true)
        create(:subscription, subscriber: developer)
        allow(user).to receive(:to_json)
        developer.notify_if_subscribed("new_checkin", user)
        expect(user).to have_received(:to_json)
      end
    end

    context "configures_device?" do
      it "returns true if developer owns device config" do
        device = create(:device)
        developer.configs.create(device: device)
        expect(developer.configures_device?(device)).to eq true
      end

      it "returns false if develpoer does not own device config" do
        device = create(:device)
        expect(developer.configures_device?(device)).to eq false
      end
    end
  end

  describe "public class methods" do
    context "responds to its methods" do
      %i(public_info default not_coposition_developers).each do |method|
        it { expect(Developer).to respond_to(method) }
      end
    end

    context "public_info" do
      it "returns all developers public info" do
        expect(Developer.public_info).to eq(Developer.select(%i(id email company_name tagline redirect_url)))
      end
    end

    context "default" do
      it "returns a developer" do
        expect(Developer.default(coposition: true)).to be_kind_of Developer
      end
    end

    context "not_coposition_developers" do
      it "returns all developers except coposition developers" do
        dev = create(:developer)
        expect(Developer.not_coposition_developers).to include(dev)
      end
    end
  end
end
