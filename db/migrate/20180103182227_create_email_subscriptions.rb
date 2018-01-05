class CreateEmailSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :email_subscriptions do |t|
      t.belongs_to :user
      t.boolean :device_inactivity, default: true
      t.boolean :friend_invite_sent, default: true
      t.boolean :round_up, default: true
      t.boolean :newsletter, default: true
    end
  end
end
