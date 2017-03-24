class CleanupCloudinary
  def self.clean
    Attachinary::File.all.each do |file|
      puts 'deleting' + file.public_id
      Cloudinary::Uploader.destroy(file.public_id, resource_type: "raw")
    end
  end
end
