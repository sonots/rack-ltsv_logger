require "bundler/gem_tasks"

task :test do
  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:test) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
end
task :default => :spec

desc 'Open an irb session preloaded with the gem library'
task :console do
    sh 'irb -rubygems -I lib'
end
task :c => :console
