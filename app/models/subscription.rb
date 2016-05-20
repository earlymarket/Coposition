class Subscription < ActiveRecord::Base
  require "net/http"

  belongs_to :user

  def send_data(data)
    uri = URI.parse("https://zapier.com/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(target_url)
    request.add_field('Content-Type', 'application/json')
    request.body = data
    response = http.request(request)
  end
end
