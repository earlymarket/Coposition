require "rails_helper"

describe ::Users::ApprovalsPresenter do
  subject(:approvals) { described_class.new(user, approvable_type: "User") }
  let(:user) do
    us = create(:user)
    Approval.add_friend(us, friend)
    Approval.add_friend(friend, us)
    us
  end
  let(:friend) { create(:user) }
  let(:device) do
    device = create(:device, user_id: user.id)
    device.permitted_users << friend
  end

  describe "Interface" do
    %i[approvable_type approved complete pending complete devices gon input_options create_approval_url].each do |meth|
      it { is_expected.to respond_to meth }
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

  describe "complete" do
    it "returns users_complete" do
      expect(approvals.complete).to eq approvals.send(:users_complete)
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
      let(:approvals) { described_class.new(user, approvable_type: "Developer") }

      it "calls Developer.not_coposition_developers" do
        allow(Developer).to receive(:not_coposition_developers).and_return user.developers
        approvals.send(:users_approved)
        expect(Developer).to have_received(:not_coposition_developers).at_least(1).times
      end

      it "calls Developer.public_info" do
        allow(Developer).to receive(:public_info)
        approvals.send(:users_approved)
        expect(Developer).to have_received(:public_info).at_least(1).times
      end
    end
  end

  describe "users_complete" do
    context "users" do
      it "returns nil" do
        expect(approvals.send(:users_complete)).to eq nil
      end
    end

    context "developers" do
      let(:approvals) { described_class.new(user, approvable_type: "Developer") }

      it "returns an ActiveRecord AssociationRelation" do
        expect(approvals.send(:users_complete)).to be_kind_of ActiveRecord::AssociationRelation
      end

      it "calls Developer.not_coposition_developers" do
        allow(Developer).to receive(:not_coposition_developers).and_return user.developers
        approvals.send(:users_complete)
        expect(Developer).to have_received(:not_coposition_developers).at_least(1).times
      end

      it "calls Developer.public_info" do
        allow(Developer).to receive(:public_info)
        approvals.send(:users_complete)
        expect(Developer).to have_received(:public_info).at_least(1).times
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
      let(:approvals) { described_class.new(user, approvable_type: "Developer") }

      it "calls user.developer_requests" do
        allow(user).to receive(:developer_requests)
        approvals.send(:users_requests)
        expect(user).to have_received(:developer_requests).twice
      end
    end
  end

  describe "friends_checkins" do
    it "returns nil if approvable_type is developer" do
      approvals = described_class.new(user, approvable_type: "Developer")
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

  describe "create_approval_url" do
    it "returns a path for creating developer approval" do
      approvals = described_class.new(user, approvable_type: "Developer")
      expect(approvals.create_approval_url).to match "create_dev_approvals"
    end

    it "returns a path for creating user approval" do
      expect(approvals.create_approval_url).to match "approvals"
    end
  end

  describe "input_options" do
    context "users" do
      it "assigns placeholder" do
        expect(approvals.input_options[:placeholder]).to match "email@email.com"
      end

      it "assigns class" do
        expect(approvals.input_options[:class]).to match "validate"
      end
    end

    context "developers" do
      let(:approvals) { described_class.new(user, approvable_type: "Developer") }

      it "assigns placeholder" do
        expect(approvals.input_options[:placeholder]).to match "name"
      end

      it "assigns class" do
        expect(approvals.input_options[:class]).to match "devs_typeahead"
      end
    end
  end
end
