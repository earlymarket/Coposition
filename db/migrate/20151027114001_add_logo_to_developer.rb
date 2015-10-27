class AddLogoToDeveloper < ActiveRecord::Migration
  def up
    add_attachment :developers, :logo
  end

  def down
    remove_attachment :developers, :logo
  end
end
