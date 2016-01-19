class AddRedirectUrlToDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :redirect_url, :string
  end
end
