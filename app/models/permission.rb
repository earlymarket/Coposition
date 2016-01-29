class Permission < ActiveRecord::Base
  
  belongs_to :device
  belongs_to :permissible, :polymorphic => true

  before_create do |p|
    if p.permissible_type == 'Developer'
      p.privilege = :complete
    else
      p.privilege = :limited
    end
  end


  # At the moment, only complete/disallowed are used. enum used for
  # extensibility.
  enum privilege: [:complete, :fogged, :disallowed, :limited]

end