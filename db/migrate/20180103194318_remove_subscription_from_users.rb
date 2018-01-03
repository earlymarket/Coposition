class RemoveSubscriptionFromUsers < ActiveRecord::Migration[5.0]
  def change
  	remove_column :users, :subscription, :string
  end
end

