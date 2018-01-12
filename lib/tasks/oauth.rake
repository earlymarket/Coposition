namespace :oauth do
  desc "Approves Coposition default mobile app for all users"
  task default_mobile_approve: :environment do
    puts "Adding access tokens for all users:"

    User.find_each(batch_size: 100) do |user|
      create_access_token user
      complete_approval user

      puts "."
    end

    puts "Done!"
  end

  def create_access_token(user)
    Doorkeeper::AccessToken.find_or_create_for(
      default_application,
      user.id,
      "public",
      nil,  # default value from server config settings
      true)  # not a default value, enabling refresh tokens here
  end

  def complete_approval(user)
    default_developer.approvals.find_by(user_id: user.id).tap do |approval|
      approval ||= Approval.add_developer(user, default_developer)
      approval.update(status: "complete")
    end
  end

  def default_application
    @default_application ||= default_developer.oauth_application
  end

  def default_developer
    @default_developer ||= Developer.default(mobile: true)
  end
end
