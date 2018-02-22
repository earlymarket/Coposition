ActiveAdmin.register User do
  permit_params :email, :username, :password, :password_confirmation, :admin, :is_active

  member_action :firebase_notification, method: :post do
    Firebase::Push.call(
      topic: resource.id,
      notification: {
        body: params[:message],
        title: params[:title]
      }
    )
    redirect_to resource_path, notice: "Message was sent"
  end

  batch_action :firebase_notification, method: :post, form: {
    title: :text,
    message:  :textarea
  } do |ids, inputs|
    batch_action_collection.find(ids).each do |user|
      Firebase::Push.call(
        topic: user.id,
        notification: {
          body: inputs[:message],
          title: inputs[:title]
        }
      )
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
    column :current_sign_in_at
    column :zapier_enabled
    column :admin
    column :is_active

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
      f.input :is_active, as: :boolean
    end
    f.actions
  end

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  show do
    default_main_content

    panel "Firebase" do
      para "Send some firebase notification to this user."
      render "firebase_form"
    end
  end
end
