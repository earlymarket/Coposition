require "rails_helper"

describe ::Users::Devices::DevicesInfoPresenter do
  subject(:info_presenter) { described_class.new(user, id: device.id) }
  let(:user) { create(:user) }
  let(:device) do
    create(:device, user_id: user.id) do |obj|
      obj.config = create(:config)
    end
  end
  let(:config) { device.config }

  describe "Interface" do
    %i(user device config config_rows).each do |method|
      it { is_expected.to respond_to method }
    end
  end

  describe "user" do
    it "returns user" do
      expect(info_presenter.user).to eq user
    end
  end

  describe "device" do
    it "returns a device" do
      expect(info_presenter.device).to be_kind_of Device
    end
  end

  describe "config" do
    it "returns a config" do
      expect(info_presenter.config).to be_kind_of Config
    end
  end

  describe "config_rows" do
    it "returns a string" do
      expect(info_presenter.config_rows).to be_kind_of String
    end

    it "returns 'No additional config' if no custom attributes" do
      config.update(custom: nil)
      expect(info_presenter.config_rows).to match "No additional config"
    end

    it "returns each attribute and value if custom attributes" do
      expect(info_presenter.config_rows).to match config.custom.first.first
    end
  end
end
