class ChangeCountryToCountryCodeInCheckins < ActiveRecord::Migration
  def change
    rename_column :checkins, :country, :country_code
  end
end
