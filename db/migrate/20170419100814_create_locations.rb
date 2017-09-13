class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.float :lat
      t.float :lng
      t.string :address
      t.timestamps
    end
  end
end
