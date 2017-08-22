ActiveAdmin.register User do
  permit_params :email, :username, :password, :password_confirmation, :admin

  member_action :smooch_message, method: :post do
    convo_api = SmoochApi::ConversationApi.new
    message = SmoochApi::MessagePost.new(role: "appMaker", type: "text", text: params[:message])
    ::Users::SendSmoochMessage.call(user: resource, message: message, api: convo_api)
    redirect_to resource_path, notice: "Message was sent"
  end

  batch_action :smooch_message, method: :post, form: {
    message:  :textarea
  } do |ids, inputs|
    convo_api = SmoochApi::ConversationApi.new
    message = SmoochApi::MessagePost.new(role: "appMaker", type: "text", text: inputs[:message])
    batch_action_collection.find(ids).each do |user|
      ::Users::SendSmoochMessage.call(user: user, message: message, api: convo_api)
    end
    redirect_to collection_path, alert: "Messages sent"
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
