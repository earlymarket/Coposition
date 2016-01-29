source 'https://rubygems.org'
ruby '2.2.2'

gem 'rename'
gem 'rails', '4.2.3'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'devise'

gem 'friendly_id', '~> 5.1.0'

gem 'responders', '~> 2.0'

gem 'rack-cors', :require => 'rack/cors'

gem 'factory_girl_rails'
gem 'faker'

gem 'geocoder'

gem "paperclip", "~> 4.3"

gem 'colorize'

gem 'simple_token_authentication'

gem 'newrelic_rpm'

gem 'slack-notifier'

gem 'materialize-sass'

gem 'will_paginate-materialize'

gem 'jquery-validation-rails'

# Use Unicorn as the app server

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development


group :development do
  gem 'derailed'
  gem 'guard-livereload', '~> 2.4', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'bullet'
  gem 'letter_opener'
  gem 'meta_request'

end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'selenium-webdriver', '2.47.1'
  gem 'cucumber-rails', :require => false
  gem 'launchy'
  gem 'database_cleaner'
  gem 'simplecov', :require => false
end
