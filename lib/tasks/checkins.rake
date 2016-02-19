namespace :checkins do

  desc "Creates a random checkin"
  task :random_checkin, [:num] => :environment do |_t, args|
    args.with_defaults(:num => 1)
    i = 0
    Checkin.transaction do
      args[:num].to_i.times do
        Checkin.create(lat: rand(-90.0..90.0), lng: rand(-180.0..180.0), uuid: Device.all.sample.uuid)
        puts "Created #{i} checkins" if i % 1000 == 0
        i += 1
      end
    end
  end

end
