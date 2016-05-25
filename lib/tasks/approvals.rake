namespace :approvals do

  desc "Makes everyone that's not already a friend request the specified user"
  task :friends, [:id]  => :environment do |_t, args|
    user = User.find_by(id: args[:id])
    non_friends = User.where.not(id: user.friends.select(:id)) \
      .where.not(id: user.friend_requests.select(:id)) \
      .where.not(id: user.id)
    request_approval(user, non_friends, 'User')
  end

  desc "Makes every developer/app that's not already approved request the specified user"
  task :apps, [:id]  => :environment do |_t, args|
    user = User.find_by(id: args[:id])
    unknown_apps = Developer.where.not(id: user.developers.select(:id)) \
      .where.not(id: user.developer_requests.select(:id))
    request_approval(user, unknown_apps, 'Developer')
  end

  def request_approval(user, approvables, type)
    approvables.each do |approvable|
      Approval.link(user, approvable, type)
      name = (type == 'Developer') ? approvable.company_name : approvable.username
      puts "#{name || 'App #' + approvable.id} sent an approval request"
    end
  end
end
