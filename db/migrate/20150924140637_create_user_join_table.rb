class CreateUserJoinTable < ActiveRecord::Migration
  def change
    create_join_table :developers, :users do |t|
      t.index [:user_id, :developer_id]
      t.index [:developer_id, :user_id], unique: true
    end
  end
end
