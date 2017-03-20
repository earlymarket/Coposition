source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '5.0.1'
gem 'pg'
gem 'redis'
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
gem 'friendly_id', '~> 5.2.0'
gem 'responders', '~> 2.0'
gem 'rename'
gem 'rack-cors', require: 'rack/cors'
gem 'factory_girl_rails'
gem 'faker'
gem 'geocoder'
gem 'colorize'
gem 'simple_token_authentication'
gem 'newrelic_rpm'
gem 'slack-notifier'
gem 'will_paginate-materialize', git: 'https://github.com/t-harps/will_paginate-materialize'
gem 'jquery-validation-rails'
gem 'inline_svg'
gem 'gon', '~> 6.1.0'
gem 'cloudinary', '~> 1.1.3'
gem 'attachinary', '~> 1.3.1'
gem "sprockets", ">= 3.0.0"
gem "sprockets-es6"
gem "bower-rails", "~> 0.10.0"
gem "gpx"
gem "activeadmin", git: "https://github.com/activeadmin/activeadmin"
gem "inherited_resources", git: "https://github.com/activeadmin/inherited_resources"
gem "activerecord-import"
gem "interactor"

group :production do
  gem 'puma'
  gem 'rack-timeout'
  gem 'rails_12factor'
end

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem 'derailed'
  gem 'guard-livereload', '~> 2.4', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem "foreman"
end

group :development, :test do
  gem "pry"
  gem "pry-rails"
  gem "pry-byebug"
  gem "rspec-rails"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "bullet"
  gem "letter_opener"
  gem "meta_request"
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false
  gem "coffeelint"
  gem "rails_best_practices", require: false
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "capybara-webkit", "~> 1.11.1"
  gem "cucumber-rails", require: false
  gem "launchy"
  gem "database_cleaner"
  gem "simplecov", require: false
  gem "rails-controller-testing"
end
