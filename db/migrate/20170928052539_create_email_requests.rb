class CreateEmailRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :email_requests do |t|
      t.integer  :user_id
      t.string   :email
      t.timestamps
    end
  end
end
