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

namespace :docker do
  desc 'Build Docker image from the Dockerfile'
  task :build do
    sh 'docker', 'build', '-t', 'web4b2017', '.'
  end

  desc 'Run in Docker container'
  task :run do
    sh 'docker', 'run', '-it', '--rm', '-p', '80:4567', 'web4b2017'
  end
end
