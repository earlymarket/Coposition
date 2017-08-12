ActiveAdmin.register Developer do
  permit_params :email, :company_name, :password, :password_confirmation

  index do
    selectable_column
    id_column

    column :email
    column :company_name
    column :config_count do |dev|
      dev.configs.count
    end
    column :approved_user_count do |dev|
      dev.users.count
    end
    column :permissioned_device_count do |dev|
      dev.devices.count
    end
    column :date_connected do |dev|
      dev.created_at
    end
    Permission::PRIVELEGE_TYPES.each do |type|
      column "#{type}_approved_percent".to_sym do |dev|
        if (total = dev.devices.count).zero?
          "n/a"
        else
          percent = dev
            .permissions
            .select{ |p| p.privilege == type.to_s }
            .size.to_f * 100 / total

          "%.2f %" % percent
        end
      end
    end

    actions
  end

  filter :email
  filter :company_name

  form do |f|
    f.inputs "Developer Details" do
      f.input :email
      f.input :company_name
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
