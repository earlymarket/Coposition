namespace :avatars do
require 'pp'

  desc "Adds a random avatar to a user (set id to 'all' to give avatars to everyone who doesn't have them)."
  task :user, [:id]  => :environment do |t, args|

    validate_id(args)

    if args[:id].downcase != 'all'
      user = User.find_by(id: args[:id])
      set_avatar(user)
      abort('Done')
    end

    users = User.all
    count_and_confirm(users)

    users.each do |user|
      set_avatar(user)
    end

    puts 'Done'

  end

  desc "Adds a random avatar to a developer/app (set id to 'all' to give avatars to everyone who doesn't have them)."
  task :app, [:id]  => :environment do |t, args|

    validate_id(args)

    if args[:id].downcase != 'all'
      app = Developer.find_by(id: args[:id])
      set_avatar(app)
      abort('Done')
    end

    apps = Developer.all
    count_and_confirm(apps)

    apps.each do |app|
      set_avatar(app)
    end

    puts 'Done'

  end

end

def count_and_confirm(resource)
  count = resource.count
  resource.each do |entity|
    if entity.avatar? then count -= 1 end
  end

  abort('Everyone already has an avatar!') if count == 0

  puts "There are #{resource.count} #{resource.name}s. #{count} without avatars. Continue? (y/n)"
  confirm = STDIN.gets.chomp

  until confirm.downcase == 'y' || confirm.downcase == 'n' do
    puts "There are #{resource.count} #{resource.name}s. #{count} without avatars. Continue? (y/n)"
    confirm = STDIN.gets.chomp
  end

  if confirm == 'n' then abort('Task aborted') end
end

def set_avatar(resource)
  uri = URI('http://uifaces.com/api/v1/random')
  unless resource.avatar?
  pp resource.as_json
    uiface = Net::HTTP.get(uri)
    uiface = JSON.parse(uiface)
    resource.avatar_url = uiface['image_urls']['epic']
    puts "Avatar set to: #{uiface['image_urls']['epic']}"
  end
end

def validate_id(args)
  is_valid = true if Float(args[:id]) rescue false
  is_valid = true if args[:id].downcase == 'all'
  abort("Bad param. Specify an ID or 'all'") unless is_valid
end
