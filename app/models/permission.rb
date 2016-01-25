class Permission < ActiveRecord::Base
  
  belongs_to :device
  belongs_to :permissible, :polymorphic => true

  before_create do |priv|
    priv.privilege = :complete
  end


  # At the moment, only complete/disallowed are used. enum used for
  # extensibility.
  enum privilege: [:complete, :fogged, :disallowed]

end