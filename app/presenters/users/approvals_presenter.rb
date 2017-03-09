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
        current_user_id: @user.id,
        friends: friends_checkins
      }
    end

    private

    def permissions
      @devices.map do |device|
        device.permissions.where(permissible_type: @approvable_type).not_coposition_developers
      end.inject(:+)
    end

    def users_approved
      @approvable_type == "Developer" ? @user.not_coposition_developers.public_info : @user.friends.public_info
    end

    def users_requests
      @approvable_type == "Developer" ? @user.developer_requests : @user.friend_requests
    end

    def friends_checkins
      return unless @approvable_type == "User"
      friends = @user.friends.includes(:devices)
      # friends is nil in tests despite @user.friends NOT being nil and this works in development
      friends.map do |friend|
        {
          userinfo: friend.public_info_hash,
          lastCheckin: friend.safe_checkin_info_for(permissible: @user, action: "last")[0]
        }
      end
    end
  end
end
