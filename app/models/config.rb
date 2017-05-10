class Config < ApplicationRecord
  include PublicActivity::Common

  belongs_to :developer
  belongs_to :device

  serialize :custom
end
