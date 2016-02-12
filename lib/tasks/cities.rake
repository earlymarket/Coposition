namespace :cities do
  desc "Imports all of the city data into the app for internal fogging"
  task import: :environment do

    # Taken from http://download.geonames.org/export/dump/
    # db/cities/1,2,3.txt together contain all info for cities with over 1000 people.

    puts "There are already #{City.count} cities." if City.count > 0

    log_city_transaction do
      quote_chars = %w(" | ~ ^ & * ` ')
      i = 0
      for x in 1..3
        begin
          CSV.foreach("db/cities/#{x}.txt", { col_sep: "\t", quote_char: quote_chars.shift }) do |row|
            City.create(name: row[1], latitude: row[4], longitude: row[5], country_code: row[8])
            puts "Parsed #{i} cities" if i % 500 == 0
            i += 1
          end
        rescue CSV::MalformedCSVError
          quote_chars.empty? ? raise : retry
        end
      end

    end
  end

  desc "Imports some city data into the app for internal fogging"
  task import_some: :environment do

    # Taken from http://download.geonames.org/export/dump/
    # db/cities/1,2,3.txt together contain all info for cities with over 1000 people.

    puts "There are already #{City.count} cities." if City.count > 0

    log_city_transaction do
      quote_chars = %w(" | ~ ^ & * ` ')
      i = 0
      begin
        CSV.foreach("db/cities/1.txt", { col_sep: "\t", quote_char: quote_chars.shift }) do |row|
          break if i == 1000
          City.create(name: row[1], latitude: row[4], longitude: row[5], country_code: row[8])
          i += 1
        end
      rescue CSV::MalformedCSVError
        quote_chars.empty? ? raise : retry
      end

    end
  end

  desc "Destroys all of the cities table in a single transaction."
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

def log_city_transaction(&block)
  puts "Constructing transaction"
  logged_time = Time.now

  City.transaction do
    yield
    puts "Beginning transaction"
  end
  print "Complete!".green
  puts" #{City.count} Cities found after #{(Time.now - logged_time).seconds} seconds"
end
