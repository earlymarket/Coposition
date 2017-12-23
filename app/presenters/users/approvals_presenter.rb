module Users
  class ApprovalsPresenter
    attr_reader :approvable_type
    attr_reader :approved
    attr_reader :pending
    attr_reader :complete
    attr_reader :devices
    attr_reader :requested
    attr_reader :sent_requests
    attr_reader :page
    attr_reader :checkins

    PIN_COLORS = {
      orange:       "#F39434",
      red:          "#D6144F",
      pink:         "#CF7FB3",
      blue:         "#3893D1",
      cian:         "#1F71A1",
      navy:         "#254394",
      yellow:       "#F0E746",
      light_purple: "#9A74B2",
      light_blue:   "#99CBEE",
      green:        "#37A837",
      purple:       "#6E3E91",
      light_green:  "#99C444"
    }.freeze

    def initialize(user, params)
      @user = user
      @approvable_type = params[:approvable_type]
      @email = params[:email]
      @order = params[:order_by]
      @page = apps_page? ? "Apps" : "Friends"
      @approved = add_color_info(users_approved)
      @complete = users_complete
      @pending = add_color_info(users_pending)
      @requested = users_requested
      @sent_requests = users_sent_requests
      @devices = user.devices
      @checkins = friends_checkins unless apps_page?
    end

    def gon
      gon =
        {
          approved: approved,
          permissions: permissions,
          current_user_id: @user.id
        }
      gon[:friends] = checkins unless apps_page?
      gon
    end

    def input_options
      if apps_page?
        { placeholder: "App name", class: "validate devs_typeahead", required: true }
      elsif @email
        { value: @email, class: "validate", required: true }
      else
        { placeholder: "email@email.com", class: "validate", required: true }
      end
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
      devices
        .map { |device| device.permissions.where(permissible_type: approvable_type).not_coposition_developers }
        .inject(:+)
    end

    def users_complete
      return nil unless apps_page? && @user.complete_developers.present?
      if @order == "approval_date"
        Developer.where(id: @user.approvals.where(status: "complete").order(:approval_date).pluck(:approvable_id))
      else
        @user.complete_developers.order(@order)
      end.not_coposition_developers.public_info
    end

    def users_approved
      apps_page? ? @user.approved_developers.not_coposition_developers.public_info : @user.friends.public_info
    end

    def users_pending
      apps_page? ? @user.developer_requests : @user.friend_requests
    end

    def users_requested
      apps_page? ? nil : @user.pending_friends
    end

    def users_sent_requests
      apps_page? ? nil : @user.email_requests
    end

    def friends_checkins
      return unless approvable_type == "User"

      friends = @user.friends.includes(:devices)
      friends.map.with_index do |friend, index|
        {
          userinfo: friend.public_info_hash,
          lastCheckin: friend.safe_checkin_info_for(permissible: @user, action: "last")[0],
          pinColor: PIN_COLORS.to_a[index % PIN_COLORS.size][0]
        }
      end
    end

    def add_color_info(list)
      return unless list

      list.each_with_index do |item, index|
        next unless item.respond_to?(:pin_color)

        item.pin_color = PIN_COLORS.to_a[index % PIN_COLORS.size][0]
      end
    end
  end
end
