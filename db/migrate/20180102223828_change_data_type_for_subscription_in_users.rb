class ChangeDataTypeForSubscriptionInUsers < ActiveRecord::Migration[5.0]
  def change
  	change_column :users, :subscription, :string, default: "all"
  end
end
