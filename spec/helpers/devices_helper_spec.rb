require 'rails_helper'

RSpec.describe DevicesHelper, type: :helper do
  let(:safebuffer) { ActiveSupport::SafeBuffer }
  let(:developer) { FactoryGirl.create :developer }
  let(:user) { FactoryGirl.create :user }
  let(:device) do
    device = FactoryGirl.create(:device, user_id: user.id)
    device.developers << developer
    device.permitted_users << user
    device
  end
  let(:config) { developer.configs.create(device_id: device.id) }
  let(:custom_config) do
    config.update(custom: { type: 'herds', mode: 'power-saving' })
    config
  end
  let(:other) { Device.update(device.id, published: true) }
  let(:friend) { FactoryGirl.create :user }
  let(:friendPresenter) { ::Users::FriendsPresenter.new(friend, { id: user.id, device_id: device.id }, 'show_device') }
  let(:devicesPresenter) { ::Users::DevicesPresenter.new(user, { id: device.id }, 'show') }

  describe '#devices_permitted_actors_for' do
    it 'returns the devices developers and permitted users' do
      expect(helper.devices_permitted_actors_for(device)).to include(developer && user)
    end
  end

  describe '#devices_last_checkin' do
    it "returns 'No Checkins found' if a checkin doesn't exist" do
      expect(helper.devices_last_checkin(device)).to match('No Checkins found')
    end

    it 'returns the last checkin address if it exists' do
      checkin = FactoryGirl.create(:checkin, device_id: device.id)
      expect(helper.devices_last_checkin(device)).to include(checkin.city)
    end
  end

  describe '#devices_shared_link' do
    it 'return nothing if not published' do
      expect(helper.devices_shared_link(device)).to be(nil)
    end
    it 'return the path to the shared device if device is published' do
      expect(helper.devices_shared_link(other)).to be_kind_of(String)
      # http://test.host/users/1/devices/5/shared
      expect(helper.devices_shared_link(other))
        .to match(%r{http://.+/users/#{device.user_id}/devices/#{device.id}/shared*+})
    end
  end

  describe '#devices_config_row' do
    it 'returns one row if no custom' do
      output = helper.devices_config_rows(config)
      expect(output).to match 'No additional config'
      expect(output.scan(/<tr>/).count).to eq 1
    end
    it 'returns each attribute and value of custom in a new row' do
      output = helper.devices_config_rows(custom_config)
      expect(output).to match custom_config.custom.keys.first.to_s
      expect(output.scan(/<tr>/).count).to eq custom_config.custom.count
    end
  end

  describe '#devices_label' do
    context 'on friends page' do
      it 'contains friend name and device name' do
        output = helper.devices_label(friendPresenter)
        expect(output).to match device.name
        expect(output).to match helper.name_or_email_name(user)
      end
    end
    context 'on personal page' do
      it 'contains device name' do
        output = helper.devices_label(devicesPresenter)
        expect(output).to_not match 'Friend:'
        expect(output).to match device.name
      end
    end
  end
end
