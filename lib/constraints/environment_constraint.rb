module Constraints
  class EnvironmentConstraint
    attr_reader :constraints
    attr_reader :path

    def initialize
      is_staging = Rails.env.staging?
      @constraints = is_staging ? nil : { subdomain: "api" }
      @path = is_staging ? "api" : ""
    end
  end
end

