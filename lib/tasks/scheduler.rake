namespace :scheduler do
  desc "Sends activity email and deletes old activities"
  task check_activity: :environment do
    check_activity
    destroy_activities
    check_approvals
  end
end

def check_activity
  return unless Time.current.friday?
  Device.all.each do |device|
    last = device.checkins.first.created_at if device.checkins.exists?
    next unless last && last < 1.week.ago
    UserMailer.no_activity_email(device).deliver_now
    firebase_notification(device.user, device.name)
  end
end

def check_approvals
  return unless Time.current.friday?
  Approval.where("status = ? AND created_at BETWEEN ? AND ?", "requested", 2.weeks.ago, 1.week.ago).each do |approval|
    UserMailer.pending_request_email(approval.approvable, approval.user)
  end
end

def destroy_activities
  PublicActivity::Activity.where("created_at < ?", 1.year.ago).destroy_all
  User.all.each do |user|
    activities = PublicActivity::Activity.where(key: "device.update", owner_id: user.id)
    recent = activities.order("created_at DESC").limit(10)
    activities.where("created_at < ?", recent.last.created_at).destroy_all if recent.exists?
  end
end

def firebase_notification(user, device_name)
  Firebase::Push.call(
    topic: user.id,
    notification: {
      body: "You have not checked in in the last 7 days on #{device_name}",
      title: "Coposition inactivity"
    }
  )
end
