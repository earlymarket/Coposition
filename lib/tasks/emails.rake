namespace :emails do
  desc "Adds a random avatar to a user."
  task check_activity: :environment do
    check_activity
  end
end

def check_activity
  return unless Time.current.friday?
  User.all.each do |user|
    last = user.checkins.first.created_at if user.checkins.exists?
    UserMailer.no_activity_email(user).deliver_now if last && last < 1.week.ago
  end
end
