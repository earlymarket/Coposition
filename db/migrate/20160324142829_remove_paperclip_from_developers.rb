class RemovePaperclipFromDevelopers < ActiveRecord::Migration
  def change
    remove_column(:developers, :logo_file_name, :string)
    remove_column(:developers, :logo_content_type, :string)
    remove_column(:developers, :logo_file_size, :integer)
    remove_column(:developers, :logo_updated_at, :datetime)
  end
end
