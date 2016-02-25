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

end
