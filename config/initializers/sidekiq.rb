template = ERB.new(File.read(Rails.root + "config/cable.yml"))
raw_config = template.result(binding)
url = YAML.load(raw_config)[Rails.env]["url"]

Sidekiq.configure_server do |config|
  config.redis = { url: url, size: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url, size: 1 }
end
