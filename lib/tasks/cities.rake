namespace :cities do
  desc "Imports all of the city data into the app for internal fogging"
  task import: :environment do

    # Taken from http://download.geonames.org/export/dump/

    puts "There are already #{City.count} cities." if City.count > 0

    log_city_transaction do

      i = 0

      CSV.foreach("db/GB.txt", { col_sep: "\t", quote_char: "`" }) do |row|
        City.create(id: row[0], name: row[1], latitude: row[4], longitude: row[5], country_code: row[8])
        puts "Parsed #{i} cities" if i % 500 == 0
        i += 1
      end

    end
  end
  desc "Destroys all of the cities table in a singe transaction."
  task destroy_all: :environment do

    print "Are you sure you want to destroy the cities table? (y/n): "
    ans = STDIN.gets.strip
    
    if ans == "y" 
      puts "Destroying cities...".red
      log_city_transaction do
        City.destroy_all
      end
    else
      puts "Cancelled"
    end  
  end
end

def log_city_transaction
  puts "Constructing transaction"
  logged_time = Time.now

  City.transaction do
    yield
    puts "Beginning transaction"
  end
  print "Complete!".green
  puts " #{City.count} Cities found after #{(Time.now - logged_time).seconds} seconds"
end