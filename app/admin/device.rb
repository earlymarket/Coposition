ActiveAdmin.register Device do
  permit_params :name, :user_id

  index do
    selectable_column
    id_column

    column :user_id
    column :checkin_count do |device|
      device.checkins.count
    end
    column :developer_count do |device|
      device.developers.count
    end
    column :user_count do |device|
      device.permitted_users.count
    end
    column :configurer do |device|
      configurer = device.configurer

      configurer.present? ? configurer.email : "Not set"
    end

    actions
  end

  form do |f|
    f.inputs "Device Details" do
      f.input :name
      f.input :user, as: :select, collection: User.pluck(:username, :id)
    end
    f.actions
  end
end