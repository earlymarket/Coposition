class CreateCheckin < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.string :status
      t.float :lat
      t.float :lng
      t.string :n_s
      t.string :e_w
      t.float :gspeed
      t.float :altitude
      t.float :course
      t.string :time
      t.string :date
      t.float :rotorspeed
      t.string :enginespeed
    end
  end
end
