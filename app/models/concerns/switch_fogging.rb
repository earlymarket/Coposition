require 'active_support/concern'

module SwitchFogging
  extend ActiveSupport::Concern

  def switch_fog
    update(fogged: !fogged)
    fogged
  end
end
