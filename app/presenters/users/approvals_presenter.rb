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
      @devices.map { |device| device.permissions.where(permissible_type: @approvable_type).not_coposition_developers }.inject(:+)
    end

    def users_approved
      @approvable_type == 'Developer' ? @user.not_coposition_developers.public_info : @user.friends.public_info
    end

    def users_requests
      @approvable_type == 'Developer' ? @user.developer_requests : @user.friend_requests
    end

    def friends_checkins
      if @approvable_type == 'User'
        friends = @user.friends.includes(:devices)
        friends.map do |friend|
          {
            userinfo: friend.public_info_hash,
            lastCheckin: friend.get_user_checkins_for(@user).limit(1).first
          }
        end
      end
    end
  end
end
