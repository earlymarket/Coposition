module Constraints
  class OAuthConstraint
    def matches?(request)
      token = Doorkeeper.authenticate(request)
      token && token.accessible?
    end
  end
end
