namespace :checkins do

  desc "Creates a random checkin"
  task :random_checkin, [:num] => :environment do |_t, args|
    args.with_defaults(:num => 1)
    i = 0
    Checkin.transaction do
      puts "Began creating checkins"
      args[:num].to_i.times do
        Device.all.sample.checkins.create(lat: rand(-90.0..90.0), lng: rand(-180.0..180.0))
        i += 1
        puts "Created #{i} checkins" if i % 1000 == 0
      end
      puts "Finished, #{i} checkins created"
    end
  end

  desc "Creates a random checkin near a city"
  task :create_near_cities, [:num] => :environment do |_t, args|
    args.with_defaults(:num => 1)
    i = 0
    Checkin.transaction do
      puts "Began creating checkins"
      args[:num].to_i.times do
        city = City.offset(rand(City.count)).first
        coords = Geocoder::Calculations.random_point_near(city, 20)
        device = Device.all.sample
        device.checkins.create(lat: coords[0], lng: coords[1])
        i += 1
        print "\rCreated #{i} checkins.".ljust(25)
        print "Current city: #{city.name}".ljust(50)
        print " Device: #{device.name}" if device.name
        print "\e[0K"
      end
      puts "\nFinished, #{i} checkins created"
    end
  end

end
