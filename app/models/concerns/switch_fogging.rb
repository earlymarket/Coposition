require 'active_support/concern'

module SwitchFogging
  extend ActiveSupport::Concern

  def switch_fog
    self.update(fogged: !self.fogged)
    self.fogged
  end

end
