module Users
  class ApprovalsPresenter
    attr_reader :approvable_type
    attr_reader :approved
    attr_reader :pending
    attr_reader :devices
    attr_reader :page

    def initialize(user, approvable_type)
      @user = user
      @approvable_type = approvable_type
      @page = apps_page? ? "Apps" : "Friends"
      @approved = users_approved
      @pending = users_requests
      @devices = user.devices
    end

    def gon
      gon =
        {
          approved: approved,
          permissions: permissions,
          current_user_id: @user.id
        }
      gon[:friends] = friends_checkins unless apps_page?
      gon
    end

    def input_options
      if apps_page?
        { placeholder: "App name", class: "validate devs_typeahead", required: true }
      else
        { placeholder: "email@email.com", class: "validate", required: true }
      end
    end

    def pending_friends
      string = ""
      pending = @user.pending_friends
      pending.each_with_index do |friend, index|
        string += friend.email
        break if index > pending.length - 2
        string += index < pending.length - 2 ? ", " : " and "
      end
      string
    end

    def create_approval_url
      if apps_page?
        Rails.application.routes.url_helpers.user_create_dev_approvals_path(@user.url_id)
      else
        Rails.application.routes.url_helpers.user_approvals_path(@user.url_id)
      end
    end

    private

    def apps_page?
      @approvable_type == "Developer"
    end

    def permissions
      devices.map do |device|
        device.permissions.where(permissible_type: approvable_type).not_coposition_developers
      end.inject(:+)
    end

    def users_approved
      apps_page? ? @user.not_coposition_developers.public_info : @user.friends.public_info
    end

    def users_requests
      apps_page? ? @user.developer_requests : @user.friend_requests
    end

    def friends_checkins
      return unless approvable_type == "User"
      friends = @user.friends.includes(:devices)
      friends.map do |friend|
        {
          userinfo: friend.public_info_hash,
          lastCheckin: friend.safe_checkin_info_for(permissible: @user, action: "last")[0]
        }
      end
    end
  end
end
