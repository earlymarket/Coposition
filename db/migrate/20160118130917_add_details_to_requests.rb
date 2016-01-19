class AddDetailsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :user_id, :integer
    add_column :requests, :action, :string
    add_column :requests, :controller, :string
  end
end
