class ChangeUserIdAndAddSubscriberTypeToSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :user_id, :subscriber_id
    add_column :subscriptions, :subscriber_type, :string
  end
end
