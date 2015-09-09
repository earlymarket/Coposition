class AddConnectionCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :connection_code, :string
  end
end
