module Firebase
  class Push
    include Interactor

    FIRE_URL = "https://fcm.googleapis.com/fcm/send".freeze
    HEADERS = {
      "Content-Type" => "application/json",
      "Authorization" => "key=#{Rails.app_config.firebase_server_key}"
    }.freeze

    delegate :data, :topic, :result,
      :device, :content_available, to: :context

    def call
      context.result = send_notification

      context.fail! unless push_success?
    end

    private

    def send_notification
      HTTParty.post(FIRE_URL, headers: HEADERS, body: payload)
    end

    def payload
      info_hash.to_json
    end

    def info_hash
      {
        to: "/topics/#{topic}",
        priority: "high",
        data: data
      }.tap do |h|
        h[:device] = device if device
        h["content-available"] = "1" if content_available
      end
    end

    def push_success?
      JSON.parse(result.body).key?("message_id")
    end
  end
end
