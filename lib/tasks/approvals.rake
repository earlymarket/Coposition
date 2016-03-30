namespace :approvals do

  desc "Makes everyone that's not already a friend request the specified user"
  task :friends, [:id]  => :environment do |t, args|
    user = User.find_by(id: args[:id])
    non_friends = User.where.not(id: user.friends.select(:id)) \
      .where.not(id: user.friend_requests.select(:id)) \
      .where.not(id: user.id)
    non_friends.each do |approvable|
      Approval.link(approvable, user, 'User')
      puts "#{approvable.username || 'User #' + approvable.id} sent a friend request"
    end
  end

  desc "Makes every developer/app that's not already approved request the specified user"
  task :apps, [:id]  => :environment do |t, args|
    user = User.find_by(id: args[:id])
    unknown_apps = Developer.where.not(id: user.developers.select(:id)) \
      .where.not(id: user.developer_requests.select(:id))

    unknown_apps.each do |approvable|
      Approval.link(user, approvable, 'Developer')
      puts "#{approvable.company_name || 'App #' + approvable.id} sent an approval request"
    end
  end

end
