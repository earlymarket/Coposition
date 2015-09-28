class AddCompanyNameToDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :company_name, :string
  end
end
