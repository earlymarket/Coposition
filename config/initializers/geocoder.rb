Geocoder.configure(
  # geocoding options
  # :timeout      => 3,           # geocoding service timeout (secs)
  # :lookup       => :google,     # name of geocoding service (symbol)
  # :language     => :en,         # ISO-639 language code
  # :use_https    => false,       # use HTTPS for lookup requests? (if supported)
  # :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
  # :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
  :api_key      => ENV["GOOGLE_MAPS_API_KEY"]
  # :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
  # :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

  # exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  # :always_raise => [],

  # calculation options
  # :units     => :mi,       # :km for kilometers or :mi for miles
  # :distances => :linear    # :spherical or :linear
)
Geocoder.configure(:lookup => :test) if Rails.env.test?

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => 51.588330,
      'longitude'    => -0.513069,
      'address'      => 'The Pilot Centre, Denham Aerodrome, Denham Aerodrome, Denham, Buckinghamshire UB9 5DF, UK',
      'city'         => 'Denham',
      'postal_code'  => 'UB9 5DF',
      'country'      => 'United Kingdom',
      'country_code' => 'GB'
    }
  ]
)