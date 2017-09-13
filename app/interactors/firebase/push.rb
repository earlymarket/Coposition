module Firebase
  class Push
    include Interactor

    FIRE_URL = "https://fcm.googleapis.com/fcm/send".freeze
    HEADERS = {
      "Content-Type" => "application/json",
      "Authorization" => "key=#{Rails.app_config.firebase_server_key}"
    }.freeze

    delegate :notification, :topic, :device, :result, to: :context

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
        notification: notification
      }.tap do |h|
        h[:device] = device if device
      end
    end

    def push_success?
      JSON.parse(result.body).key?("message_id")
    end
  end
end
