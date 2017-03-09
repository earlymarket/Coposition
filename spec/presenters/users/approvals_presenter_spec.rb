require "rails_helper"

describe ::Users::ApprovalsPresenter do
  subject(:approvals) { described_class.new(user, "User") }
  let(:user) do
    us = FactoryGirl.create(:user)
    us.friends << friend
    us
  end
  let(:friend) { FactoryGirl.create(:user) }
  let(:device) do
    device = FactoryGirl.create(:device, user_id: user.id)
    device.permitted_users << friend
  end

  describe "Interface" do
    %i(approvable_type approved pending devices gon).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "approvable_type" do
    it "returns a string" do
      expect(approvals.approvable_type).to be_kind_of String
    end
  end

  describe "approved" do
    it "returns users_approved" do
      expect(approvals.approved).to eq approvals.send(:users_approved)
    end
  end

  describe "pending" do
    it "returns users_requests" do
      expect(approvals.pending).to eq approvals.send(:users_requests)
    end
  end

  describe "devices" do
    it "returns collection of devices" do
      expect(approvals.devices).to be_kind_of ActiveRecord::Associations::CollectionProxy
    end
  end

  describe "gon" do
    it "returns a hash" do
      expect(approvals.gon).to be_kind_of Hash
    end

    it "calls permissions" do
      allow(approvals).to receive(:permissions)
      approvals.gon
      expect(approvals).to have_received(:permissions)
    end

    it "calls friends_checkins" do
      allow(approvals).to receive(:friends_checkins)
      approvals.gon
      expect(approvals).to have_received(:friends_checkins)
    end
  end

  describe "permissions" do
    it "returns nil if no devices" do
      expect(approvals.send(:permissions)).to eq nil
    end

    context "with device" do
      before do
        device
      end

      it "returns an active record AssociationRelation" do
        expect(approvals.send(:permissions)).to be_kind_of ActiveRecord::AssociationRelation
      end

      it "calls Permission.not_coposition_developers" do
        allow(Permission).to receive(:not_coposition_developers)
        approvals.send(:permissions)
        expect(Permission).to have_received(:not_coposition_developers)
      end

      it "returns an array containing permissions" do
        expect(approvals.send(:permissions)[0]).to be_kind_of Permission
      end
    end
  end

  describe "users_approved" do
    it "returns an ActiveRecord AssociationRelation" do
      expect(approvals.send(:users_approved)).to be_kind_of ActiveRecord::AssociationRelation
    end

    context "users" do
      it "calls User.public_info" do
        allow(User).to receive(:public_info)
        approvals.send(:users_approved)
        expect(User).to have_received(:public_info).twice
      end
    end

    context "developers" do
      let(:approvals) { described_class.new(user, "Developer") }

      it "calls user.not_coposition_developers" do
        allow(user).to receive(:not_coposition_developers).and_return user.developers
        approvals.send(:users_approved)
        expect(user).to have_received(:not_coposition_developers).twice
      end

      it "calls Developer.public_info" do
        allow(Developer).to receive(:public_info)
        approvals.send(:users_approved)
        expect(Developer).to have_received(:public_info).twice
      end
    end
  end

  describe "users_requests" do
    it "returns an ActiveRecord Associations CollectionProxy" do
      expect(approvals.send(:users_requests)).to be_kind_of ActiveRecord::Associations::CollectionProxy
    end

    context "users" do
      it "calls user.friend_requests" do
        allow(user).to receive(:friend_requests)
        approvals.send(:users_requests)
        expect(user).to have_received(:friend_requests).twice
      end
    end

    context "developers" do
      let(:approvals) { described_class.new(user, "Developer") }

      it "calls user.developer_requests" do
        allow(user).to receive(:developer_requests)
        approvals.send(:users_requests)
        expect(user).to have_received(:developer_requests).twice
      end
    end
  end

  describe "friends_checkins" do
    it "returns nil if approvable_type is developer" do
      approvals = described_class.new(user, "Developer")
      expect(approvals.send(:friends_checkins)).to eq nil
    end

    it "returns an array" do
      expect(approvals.send(:friends_checkins)).to be_kind_of Array
    end

    it "returns an array of hashes" do
      # This test should pass, for some reason calling any method on a collection proxy returns nothing
      expect(approvals.send(:friends_checkins)[0]).to be_kind_of Hash
    end
  end
end
