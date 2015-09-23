class AddApiKeyToDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :api_key, :string
  end
end
