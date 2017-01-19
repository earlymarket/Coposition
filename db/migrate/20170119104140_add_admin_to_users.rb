class AddAdminToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :admin, :boolean, null: false, default: false

    User.create!(
      username: "admin_user",
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
      admin: true
    )
  end

  def down
    User.find_by(email: "admin@example.com").try(:delete)

    remove_column :users, :admin
  end
end
