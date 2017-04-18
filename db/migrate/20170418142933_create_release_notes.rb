class CreateReleaseNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :release_notes do |t|
      t.string :version
      t.string :content
      t.string :application
      t.timestamps
    end
  end
end
