# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
APP_PATH = File.expand_path('../config/application', __FILE__)
working_directory = APP_PATH

run Rails.application
