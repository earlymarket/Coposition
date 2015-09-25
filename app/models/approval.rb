class Approval < ActiveRecord::Base

  before_create do |app|
    app.approved = false
    true
  end

  belongs_to :user
  belongs_to :developer

end