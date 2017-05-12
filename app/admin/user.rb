ActiveAdmin.register User do
  permit_params :email, :username, :password, :password_confirmation, :admin

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :device_count do |user|
      user.devices.count
    end
    column :app_count do |_|
      "Not set"
    end
    column :friend_count do |user|
      user.friends.count
    end
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
end
