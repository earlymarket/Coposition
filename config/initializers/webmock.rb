if Rails.env.test?
  require "webmock/rspec"
  WebMock.allow_net_connect!
end
