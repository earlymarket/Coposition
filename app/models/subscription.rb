class Subscription < ApplicationRecord
  require "net/http"

  belongs_to :subscriber, polymorphic: true

  def send_data(data)
    uri = URI.parse("https://zapier.com/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(target_url)
    request.add_field("Content-Type", "application/json")
    request.body = data.to_json
    check_response(http.request(request))
  end

  def check_response(response)
    if response.code == "410"
      destroy
    elsif !response.is_a? Net::HTTPSuccess
      puts response
    end
  end
end
