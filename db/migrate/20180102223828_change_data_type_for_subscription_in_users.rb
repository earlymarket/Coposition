class ChangeDataTypeForSubscriptionInUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.change :subscription, :string, default: "all"
    end
  end

  def self.down
    change_table :users do |t|
      t.change :subscription, "boolean USING CAST(subscription AS boolean)", default: true
    end
  end
end
