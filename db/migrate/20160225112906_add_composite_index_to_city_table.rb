class AddCompositeIndexToCityTable < ActiveRecord::Migration
  def change
    add_index :cities, [:latitude, :longitude]
  end
end
