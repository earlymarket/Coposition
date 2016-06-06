namespace :avatars do
  require 'pp'

  desc 'Adds a random avatar to a user.'
  task :user, [:id] => :environment do |_t, args|
    find_and_set_avatar(args, 'User')
  end

  desc 'Adds a random avatar to all users without an avatar.'
  task users: :environment do
    users = User.all
    count_and_confirm(users)
    users.each do |user|
      add_avatar(user)
    end
  end

  desc 'Adds a random avatar to an app/developer.'
  task :app, [:id] => :environment do |_t, args|
    find_and_set_avatar(args, 'Developer')
  end

  desc 'Adds a random avatar to all apps/developers without an avatar.'
  task apps: :environment do
    apps = Developer.all
    count_and_confirm(apps)
    apps.each do |app|
      add_avatar(app)
    end
  end
end

def find_and_set_avatar(args, type)
  validate_id(args)
  app = type.constantize.find_by(id: args[:id])
  add_avatar(app)
end

def count_and_confirm(resource)
  count = resource.count
  resource.each { |entity| count -= 1 if entity.avatar? }

  abort('Everyone already has an avatar!') if count == 0

  confirm = ''

  until confirm =~ /[yn]/i
    puts "There are #{resource.count} #{resource.name}s. #{count} without avatars. Continue? (y/n)"
    confirm = STDIN.gets.chomp
  end

  abort('Task aborted') if confirm =~ /[n]/i
end

def add_avatar(resource)
  # uri = URI('http://uifaces.com/api/v1/random')
  uri = URI('http://api.randomuser.me/')
  return if resource.avatar?
  pp resource.as_json
  uiface = Net::HTTP.get(uri)
  uiface = JSON.parse(uiface)
  # avatar_url = uiface['image_urls']['epic']
  avatar_url = uiface['results'].first['picture']['large']
  resource.avatar_url = avatar_url
  puts "Avatar set to: #{avatar_url}"
end

def validate_id(args)
  is_valid = begin
    true if Float(args[:id])
  rescue ArgumentError
    false
  end
  abort('Bad param. Specify an ID.') unless is_valid
end
