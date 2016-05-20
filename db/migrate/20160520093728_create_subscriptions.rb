class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :url
      t.string :event

      t.timestamps null: false
    end
  end
end
