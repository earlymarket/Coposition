module Users
  class PermissionsPresenter
    attr_reader :permissible
    attr_reader :device
    attr_reader :permissions
    attr_reader :permission

    def initialize(user, params, action)
      @user = user
      @devices = user.devices
      @params = params
      if action == 'index'
        params[:from] == 'devices' ? devices_index : approvals_index(params[:from])
      else
        update
      end
    end

    def devices_index
      @device = Device.find(@params[:device_id])
      @permissions = @device.permissions.includes(:permissible).order(:permissible_type, :id)
    end

    def approvals_index(from)
      device_ids = @devices.select(:id)
      model = from == 'friends' ? User : Developer
      @permissible = model.find(@params[:device_id]) # device_id = user_id/developer_id, permissions for friend/dev
      @permissions = Permission.where(device_id: device_ids,
                                      permissible_id: @permissible.id, permissible_type: model.to_s)
    end

    def update
      @permission = Permission.find(@params[:id])
    end

    def gon(from)
      case from
      when 'devices' then devices_gon
      when 'apps' then apps_gon
      when 'friends' then friends_gon
      end
    end

    def devices_gon
      {
        permissions: @devices.map(&:permissions).inject(:+),
        current_user_id: @user.id,
        devices: @user.devices
      }
    end

    def apps_gon
      {
        permissions: approvals_permissions('Developer'),
        current_user_id: @user.id,
        approved: @user.developers
      }
    end

    def friends_gon
      {
        permissions: approvals_permissions('User'),
        current_user_id: @user.id,
        approved: @user.friends
      }
    end

    private

    def approvals_permissions(type)
      @devices.map { |device| device.permissions.where(permissible_type: type) }.inject(:+)
    end
  end
end
