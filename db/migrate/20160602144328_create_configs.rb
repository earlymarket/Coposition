class CreateConfigs < ActiveRecord::Migration
  def change
    create_table :configs do |t|
      t.integer :developer_id
      t.integer :device_id
      t.text :custom

      t.timestamps null: false
    end
  end
end
