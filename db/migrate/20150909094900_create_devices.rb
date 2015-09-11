class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :imei, unique: true
    end
  end
end
