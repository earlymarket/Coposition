class CreateRequestsTable < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :developer_id
      t.datetime :created_at
    end
  end
end
