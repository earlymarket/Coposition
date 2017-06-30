namespace :oauth do
  desc "Approves Coposition default mobile app for all users"
  task default_mobile_approve: :environment do
    puts "Adding access tokens for all users:"

    User.find_each(batch_size: 100) do |user|
      Doorkeeper::AccessToken.find_or_create_for(
        default_application,
        user.id,
        "public",
        7200,  # default value from server config settings
        true)  # not a default value, enabling refresh tokens here

      puts "."
    end

    puts "Done!"
  end

  def default_application
    Developer.default(mobile: true).oauth_application
  end
end
