module Users
  class ApprovalsPresenter
    attr_reader :approvable_type
    attr_reader :approved
    attr_reader :pending
    attr_reader :devices

    def initialize(user, approvable_type)
      @user = user
      @approvable_type = approvable_type
      @approved = users_approved
      @pending = users_requests
      @devices = user.devices
    end

    def gon
      {
        approved: @approved,
        permissions: permissions,
        current_user_id: @user.id
      }
    end

    private

    def permissions
      @devices.map { |device| device.permissions.where(permissible_type: @approvable_type) }.inject(:+)
    end

    def users_approved
      @approvable_type == 'Developer' ? @user.developers.public_info : @user.friends.public_info
    end

    def users_requests
      @approvable_type == 'Developer' ? @user.developer_requests : @user.friend_requests
    end
  end
end
