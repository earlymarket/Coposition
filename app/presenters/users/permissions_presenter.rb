module Users
  class PermissionsPresenter < ApplicationPresenter
    attr_reader :permissible
    attr_reader :device
    attr_reader :permissions
    attr_reader :permission

    def initialize(user, params, action)
      @user = user
      @devices = user.devices.includes(:permissions)
      @params = params
      if action == "index"
        params[:from] == "devices" ? devices_index : approvals_index(params[:from])
      else
        update
      end
    end

    def devices_index
      @device = Device.find(@params[:device_id])
      @permissions =
        device
        .permissions
        .includes(:permissible)
        .order(:permissible_type, :permissible_id)
        .not_coposition_developers.reverse
    end

    def approvals_index(from)
      device_ids = @devices.select(:id)
      model = from == "friends" ? User : Developer
      @permissible = model.find(@params[:device_id]) # device_id = user_id/developer_id, permissions for friend/dev
      @permissions = Permission.where(device_id: device_ids,
                                      permissible_id: permissible.id, permissible_type: model.to_s)
                               .order(:device_id)
                               .includes(:permissible, :device)
    end

    def update
      @permission = Permission.find(@params[:id])
    end

    def gon(from)
      send from + "_gon"
    end

    def devices_gon
      {
        checkins: devices_index_checkins,
        permissions: @devices.map { |device| device.permissions.not_coposition_developers }.inject(:+),
        current_user_id: @user.id,
        devices: @user.devices
      }
    end

    def apps_gon
      {
        permissions: approvals_permissions("Developer"),
        current_user_id: @user.id,
        approved: @user.developers.not_coposition_developers.public_info
      }
    end

    def friends_gon
      {
        permissions: approvals_permissions("User"),
        current_user_id: @user.id,
        approved: @user.friends.public_info
      }
    end

    private

    def devices_index_checkins
      @devices
        .includes(:checkins)
        .map { |device| device.past_checkins.first.as_json.merge(device: device.name) if device.past_checkins.present? }
        .compact
    end

    def approvals_permissions(type)
      @devices.map { |device| device.permissions.where(permissible_type: type).not_coposition_developers }
              .inject(:+)
    end
  end
end
