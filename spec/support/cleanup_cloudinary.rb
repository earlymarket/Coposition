class CleanupCloudinary
  def self.clean
    Attachinary::File.all.each do |file|
      Cloudinary::Uploader.destroy(file.public_id, resource_type: "raw")
    end
  end
end
