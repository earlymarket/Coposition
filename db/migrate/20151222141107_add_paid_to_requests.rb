class AddPaidToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :paid, :boolean, default: false
  end
end
