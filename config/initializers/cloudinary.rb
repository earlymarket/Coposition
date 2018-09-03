# Cloudinary.config do |config|
#   if Rails.env.development?
#     config.cloud_name = "coposition"
#     config.api_key = ENV["CLOUDINARY_API_KEY"]
#     config.api_secret = ENV["CLOUDINARY_API_SECRET"]
#     config.enhance_image_tag = true
#     config.static_image_support = false
#   elsif Rails.env.production?
#     config.cloud_name = ENV["coposition"]
#     config.api_key = ENV["CLOUDINARY_API_KEY"]
#     config.api_secret = ENV["CLOUDINARY_API_SECRET"]
#     config.enhance_image_tag = true
#     config.static_image_support = true
#   elsif Rails.env.test?
#     config.cloud_name = ENV["coposition"]
#     config.api_key = ENV["CLOUDINARY_API_KEY"]
#     config.api_secret = ENV["CLOUDINARY_API_SECRET"]
#     config.enhance_image_tag = true
#     config.static_image_support = false
#   elsif Rails.env.staging?
#     config.cloud_name = ENV["coposition"]
#     config.api_key = ENV["CLOUDINARY_API_KEY"]
#     config.api_secret = ENV["CLOUDINARY_API_SECRET"]
#     config.enhance_image_tag = true
#     config.static_image_support = true
#   end
# end
