class AddZapierEnabledToDevelopers < ActiveRecord::Migration[5.0]
  def change
  	add_column :developers, :zapier_enabled, :boolean, default: false
  end
end
