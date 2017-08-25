SmoochApi.configure do |config|
  # Configure API key authorization: jwt
  config.api_key["Authorization"] = ENV["SMOOCH_JWT"]
  config.api_key_prefix["Authorization"] = "Bearer"
end
