class AddNotificationTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notification_token, :string
    add_index :users, :notification_token, unique: true
  end
end
