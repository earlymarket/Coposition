class RemoveCheckinFields < ActiveRecord::Migration
  def change
    remove_column :checkins, :n_s, :string
    remove_column :checkins, :e_w, :string
    remove_column :checkins, :gspeed, :float
    remove_column :checkins, :altitude, :float
    remove_column :checkins, :course, :float
    remove_column :checkins, :time, :string
    remove_column :checkins, :date, :string
    remove_column :checkins, :rotorspeed, :float
    remove_column :checkins, :enginespeed, :string
    remove_column :checkins, :status, :string
  end
end











