class AddTaglineToDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :tagline, :string
  end
end
