desc "Run specs in parallel"
task :parallel, [:cores] do |_task, args|
  cores = [args[:cores]]
  puts "Running specs in parallel with #{cores} cores"
  Rake::Task["parallel:spec"].invoke(*cores)
end
