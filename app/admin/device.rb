ActiveAdmin.register Device do
  remove_filter :checkins
  permit_params :name, :user_id

  controller do
    def scoped_collection
      end_of_association_chain.active_devices
    end
  end

  config.per_page = [10, 50, 100]

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
