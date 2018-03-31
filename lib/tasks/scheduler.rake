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
  User.all.each do |user|
    inactive = user.devices.map do |device|
      next unless valid_device(device)
      firebase_notification(user, device)
      device
    end.compact
    UserMailer.no_activity_email(user, inactive).deliver_now if inactive.length.positive?
  end
end

def valid_device(device)
  checkins = device.checkins
  custom = device.config.custom
  checkins.exists? && checkins.first.created_at < 1.week.ago && custom && custom["assigned"]
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

def firebase_notification(user, device)
  Firebase::Push.call(
    topic: user.id,
    notification: {
      body: "You have not checked in in the last 7 days on #{device.name}",
      title: "Coposition inactivity"
    }
  )
end
