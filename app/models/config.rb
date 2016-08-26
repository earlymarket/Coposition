class Config < ApplicationRecord
  belongs_to :developer
  belongs_to :device

  serialize :custom
end
