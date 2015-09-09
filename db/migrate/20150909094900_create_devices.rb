class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :imei
    end
  end
end
