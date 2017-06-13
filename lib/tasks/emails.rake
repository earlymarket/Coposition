namespace :emails do
  desc "Adds a random avatar to a user."
  task check_activity: :environment do
    User.all.each do |user|
      last = user.checkins.first.created_at if user.checkins.present?
      UserMailer.no_activity_email(user).deliver_now if last && last < 1.week.ago
    end
  end
end
