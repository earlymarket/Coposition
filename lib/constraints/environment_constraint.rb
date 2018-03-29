module Constraints
  class EnvironmentConstraint
    attr_reader :subdomain
    attr_reader :path

    def initialize
      staging? = Rails.env.staging?
      @subdomain = staging? ? "" : "api"
      @path = staging? ? "api" : ""
    end
  end
end

