class Permission < ActiveRecord::Base
  
  belongs_to :device
  belongs_to :permissible, :polymorphic => true

  before_create do |p|
    p.privilege = :complete
  end

  enum privilege: [:disallowed, :last_only, :complete]

end