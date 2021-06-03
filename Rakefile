# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks
Rake::Task["default"].clear

if %w[development test].include?(Rails.env)
  task :default do
    cores = ENV["PARALLEL_CORES"]
    Rake::Task["parallel:spec"].invoke(cores)
    Rake::Task["js_spec"].invoke
    Rake::Task["lint:ruby"].invoke
    Rake::Task["lint:scss"].invoke
    Rake::Task["lint:erb"].invoke
    Rake::Task["brakeman"].invoke
  end
end
