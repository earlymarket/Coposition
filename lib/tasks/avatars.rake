namespace :avatars do
require 'pp'

  desc "Adds a random avatar to a user."
  task :user, [:id]  => :environment do |_t, args|
    find_and_set_avatar(args, 'User')
  end

  desc "Adds a random avatar to all users without an avatar."
  task :'users:all' => :environment do
    users = User.all
    count_and_confirm(users)
    users.each do |user|
      set_avatar(user)
    end
  end

  desc "Adds a random avatar to an app/developer."
  task :app, [:id]  => :environment do |_t, args|
    find_and_set_avatar(args, 'Developer')
  end

  desc "Adds a random avatar to all apps/developers without an avatar."
  task :'apps:all' => :environment do
    apps = Developer.all
    count_and_confirm(apps)
    apps.each do |app|
      set_avatar(app)
    end
  end

end

def find_and_set_avatar(args, type)
  validate_id(args)
  app = type.constantize.find_by(id: args[:id])
  set_avatar(app)
end

def count_and_confirm(resource)
  count = resource.count
  resource.each do |entity|
    if entity.avatar? then count -= 1 end
  end

  abort('Everyone already has an avatar!') if count == 0

  confirm = ''

  until confirm.downcase == 'y' || confirm.downcase == 'n' do
    puts "There are #{resource.count} #{resource.name}s. #{count} without avatars. Continue? (y/n)"
    confirm = STDIN.gets.chomp
  end

  if confirm == 'n' then abort('Task aborted') end
end

def set_avatar(resource)
  # uri = URI('http://uifaces.com/api/v1/random')
  uri = URI('http://api.randomuser.me/')
  unless resource.avatar?
  pp resource.as_json
    uiface = Net::HTTP.get(uri)
    uiface = JSON.parse(uiface)
    # avatar_url = uiface['image_urls']['epic']
    avatar_url = uiface['results'].first['picture']['large']
    resource.avatar_url = avatar_url
    puts "Avatar set to: #{avatar_url}"


  end
end

def validate_id(args)
  is_valid = true if Float(args[:id]) rescue false
  abort("Bad param. Specify an ID.") unless is_valid
end
