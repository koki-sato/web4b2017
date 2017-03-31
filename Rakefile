# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

desc 'Prepare for development'
task :setup do
  sh 'bundle', 'install'
end

desc 'Launch dynamic development server'
task :server do
  sh 'bundle', 'exec', 'rackup'
end
