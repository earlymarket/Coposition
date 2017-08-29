class DropLocations < ActiveRecord::Migration[5.0]
  def change
    drop_table :locations do |t|
      t.string :name
      t.float :lat
      t.float :lng
      t.string :address
      t.timestamps
    end
  end
end
