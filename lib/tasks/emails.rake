namespace :scheduler do
  desc "Adds a random avatar to a user."
  task check_activity: :environment do
    check_activity
    destroy_activities
  end
end

def check_activity
  return unless Time.current.friday?
  User.all.each do |user|
    last = user.checkins.first.created_at if user.checkins.exists?
    UserMailer.no_activity_email(user).deliver_now if last && last < 1.week.ago
  end
end

def destroy_activities
  PublicActivity::Activity.where("created_at < ?", 1.year.ago).destroy_all
  User.all.each do |user|
    activities = PublicActivity::Activity.where(key: "device.update", owner_id: user.id)
    recent = activities.order("created_at DESC").limit(10)
    activities.destroy_all("created_at < ?", recent.last.created_at) if recent.exists?
  end
end
