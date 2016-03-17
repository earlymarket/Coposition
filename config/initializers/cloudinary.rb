Cloudinary.config do |config|
  config.cloud_name = 'coposition'
  config.api_key = ENV['CLOUDINARY_API_KEY']
  config.api_secret = ENV['CLOUDINARY_API_SECRET']
  config.cdn_subdomain = true
end
