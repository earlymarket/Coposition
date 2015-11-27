class AddTimestampsToCheckin < ActiveRecord::Migration
  def change_table
    add_column(:checkins, :created_at, :datetime)
    add_column(:checkins, :updated_at, :datetime)
  end
end
