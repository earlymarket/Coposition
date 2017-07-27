ActiveAdmin.register User do
  permit_params :email, :username, :password, :password_confirmation, :admin

  member_action :smooch_message, method: :post do
    convo_api = SmoochApi::ConversationApi.new
    message = SmoochApi::MessagePost.new(role: "appMaker", type: "text", text: params[:message])
    resource.devices.each do |device|
      next unless device.config && device.config.custom && (id = device.config.custom["smoochId"])

      begin
        convo_api.post_message(id, message)
      rescue SmoochApi::ApiError => e
        puts "Exception when calling ConversationApi->post_message: #{e}"
      end
    end

    redirect_to resource_path, notice: "Message was sent"
  end

  index do
    selectable_column
    id_column

    column :email
    column :username
    column :device_count do |user|
      user.devices.count
    end
    column :app_count do |user|
      user.developers.count
    end
    column :friend_count do |user|
      user.friends.count
    end
    column :zapier_enabled
    column :admin

    actions
  end

  filter :email
  filter :username

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :username
      f.input :password
      f.input :password_confirmation
      f.input :admin
    end
    f.actions
  end

  show do
    default_main_content

    panel "Smooch" do
      para "Send some smooch message for this user."
      render "smooch_form"
    end
  end
end
