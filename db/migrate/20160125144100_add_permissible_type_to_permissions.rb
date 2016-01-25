class AddPermissibleTypeToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :permissible_type, :string
  end
end
