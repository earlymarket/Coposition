class CreateUserJoinTable < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.belongs_to :developer, index: true
      t.belongs_to :user, index: true
      t.datetime :approval_date
      t.timestamps null: false
    end
  end
end
