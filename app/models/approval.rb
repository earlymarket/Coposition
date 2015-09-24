class Approval < ActiveRecord::Base

  belongs_to :user
  belongs_to :developer

end