class Config < ActiveRecord::Base
  belongs_to :developer
  belongs_to :device

  serialize :custom
end
