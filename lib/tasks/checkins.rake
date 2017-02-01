namespace :checkins do
  desc 'Creates a random checkin'
  task :random_checkin, [:num] => :environment do |_t, args|
    args.with_defaults(num: 1)
    i = 0
    Checkin.transaction do
      puts 'Began creating checkins'
      args[:num].to_i.times do
        Device.all.sample.checkins.create(lat: rand(-90.0..90.0), lng: rand(-180.0..180.0))
        i += 1
        puts "Created #{i} checkins" if i % 1000 == 0
      end
      puts "Finished, #{i} checkins created"
    end
  end

  desc 'Creates a random checkin near a city'
  task :create_near_cities, [:count, :device_id] => :environment do |_t, args|
    args.with_defaults(count: 1, device_id: nil)
    selected_device = Device.find(args[:device_id]) if args[:device_id]
    i = 0
    start_time = Time.now
    Checkin.transaction do
      puts 'Began creating checkins'
      args[:count].to_i.times do
        city = City.offset(rand(City.count)).first
        coords = Geocoder::Calculations.random_point_near(city, 20)
        time = rand(0..1000).hour.ago
        device = selected_device || Device.all.sample
        device.checkins.create(lat: coords[0], lng: coords[1], created_at: time)
        i += 1
        print "\rCreated #{i} checkins.".ljust(25)
        print "Current city: #{city.name}".ljust(60)
        print "Device: #{device.name}".ljust(25) if device.name
        print " Time elapsed: #{Time.now - start_time} seconds"
        print "\e[0K"
      end
      puts "\nFinished. #{i} checkins created."
    end
  end

  desc 'Updates output fields of checkins'
  task :update_output, [:device_id] => :environment do |_t, args|
    if (device = Device.find_by(id: args[:device_id]))
      Checkin.transaction do
        unfogged = device.checkins.where(fogged: false)
        device.fogged ? unfogged.each(&:set_output_to_fogged) : unfogged.each(&:set_output_to_unfogged)
      end
    end
  end

  desc 'Imports checkins from CSV'
  task :import, [:filepath, :device_id] => :environment do |_t, args|
    Checkin.transaction do
      CSV.foreach(args[:filepath], headers: true) do |row|
        checkin = Checkin.find_by_id(row['id']) || Checkin.new
        checkin.attributes = row.to_hash.slice('lat', 'lng', 'created_at', 'fogged')
        checkin.device_id = args[:device_id]
        checkin.save!
      end
    end
  end
end
