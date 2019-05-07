require "rake/testtask"

namespace :test do
  Rake::TestTask.new(real_world_benchmark: ["test:benchmark"]) do |t|
    t.libs << "test"
    t.pattern = "test/performance/**/*_test.rb"
  end
end
