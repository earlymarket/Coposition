class AddDelayedToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :delayed, :integer
  end
end
