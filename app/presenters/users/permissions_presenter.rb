module Users
  class PermissionsPresenter
    attr_reader :permission

    def initialize(user, params)
      @user = user
      @permission = Permission.find(params[:id])
      @devices = @user.devices.order(:id).includes(:permissions)
    end

    def gon
      {
        checkins: cal_checkins,
        permissions: @devices.map(&:permissions).inject(:+),
        current_user_id: @user.id,
        devices: @devices
      }
    end

    private

    def cal_checkins
      checkins = @user.checkins
      checkins.calendar_data if checkins.exists?
    end
  end
end
