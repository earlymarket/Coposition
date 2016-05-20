class AddWebhookKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :webhook_key, :string
    add_index :users, :webhook_key, unique: true
  end
end
