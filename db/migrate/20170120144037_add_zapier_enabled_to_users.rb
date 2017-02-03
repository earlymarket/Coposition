class AddZapierEnabledToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :zapier_enabled, :boolean, default: false
  end
end
