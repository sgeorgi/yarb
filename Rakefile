# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Yarb::Application.load_tasks

desc "Run all specs without caches"
task :all do
  `rm -Rf #{Rails.root}/tmp/statistic*`
  `rm -Rf #{Rails.root}/tmp/application_helper*`
  Rake::Task['default'].invoke
end

desc "Run specs without js (fast)"
task :fast do
  system "rspec", "-t", "~js"
end

desc "Run unit tests only"
task :units do
  system "rspec", "spec/models", "spec/lib"
end

desc "Run everything whith detailed output"
task :long do
  system "rspec", "-f", "d", "spec/"
  system "guard-jasmine"
end

desc "Deploy (needs authentication with ssh-keys)"
task :deploy do
  system "yard"
  system "rsync", "-avze", "ssh", "doc", "www-data@dav.iboard.cc:/var/www/dav/container/yarb/"
end


