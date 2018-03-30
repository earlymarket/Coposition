class AddLastWebVisitAtAndLastMobileVisitAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_web_visit_at, :date
    add_column :users, :last_mobile_visit_at, :date
  end
end
