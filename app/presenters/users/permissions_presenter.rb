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
      send "#{params[:from]}_#{action}"
    end

    def devices_index
      @device = Device.find(@params[:device_id])
      @permissions = @device.permissions.includes(:permissible).order(:permissible_type, :id)
    end

    def apps_index
      device_ids = @devices.select(:id)
      @permissible = Developer.find(@params[:device_id]) #  device_id = developer_id, permissions for app
      @permissions = Permission.where(device_id: device_ids,
                                      permissible_id: @permissible.id, permissible_type: 'Developer')
    end

    def friends_index
      device_ids = @devices.select(:id)
      @permissible = User.find(@params[:device_id]) # device_id = user_id, permissions for friend
      @permissions = Permission.where(device_id: device_ids, permissible_id: @permissible.id, permissible_type: 'User')
    end

    def devices_update
      @permission = Permission.find(@params[:id])
    end

    def apps_update
      @permission = Permission.find(@params[:id])
    end

    def friends_update
      @permission = Permission.find(@params[:id])
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
