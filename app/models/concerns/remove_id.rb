require 'active_support/concern'

module RemoveId
  extend ActiveSupport::Concern
  def remove_id
    attributes.delete_if { |key, _value| key == 'id' }
  end
end
