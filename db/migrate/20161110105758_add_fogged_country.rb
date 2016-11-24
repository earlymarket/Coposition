class AddFoggedCountry < ActiveRecord::Migration[5.0]
  def change
    add_column :checkins, :fogged_country_code, :string
  end
end
