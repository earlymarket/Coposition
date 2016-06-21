module Users
  class PermissionsPresenter
    attr_reader :permission

    def initialize(user, params)
      @user = user
      @permission = Permission.find(params[:id])
      @devices = @user.devices.order(:id).includes(:permissions)
      @params = params
    end

    def gon
      {
        checkins: cal_checkins,
        permissions: permissions,
        current_user_id: @user.id,
        devices: @devices
      }
    end

    private

    def cal_checkins
      checkins = @user.checkins
      checkins.calendar_data if checkins.exists?
    end

    def permissions
      page = @params[:page]
      if page == 'devices'
        @devices.map(&:permissions).inject(:+)
      elsif page == 'apps'
        @devices.map { |device| device.permissions.where(permissible_type: 'Developer') }.inject(:+)
      elsif page == 'friends'
        @devices.map { |device| device.permissions.where(permissible_type: 'User') }.inject(:+)
      end
    end
  end
end
