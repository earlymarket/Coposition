require 'active_support/concern'

module SharedMethods
  extend ActiveSupport::Concern
  
  def switch_fog
    self.fogged = !self.fogged
    save
    self.fogged
  end

end