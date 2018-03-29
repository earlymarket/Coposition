module Constraints
  class EnvironmentConstraint
    attr_reader :subdomain
    attr_reader :path

    def initialize
      is_staging = Rails.env.staging?
      @subdomain = is_staging ? "" : "api"
      @path = is_staging ? "api" : ""
    end
  end
end

