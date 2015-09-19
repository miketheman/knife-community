#!/usr/bin/env rake
require "bundler/gem_tasks"

task :default => [:spec, :features]

begin
  require 'appraisal'
rescue LoadError
  puts 'Unable to load appraisal gem - will test against only latest version of the dependency.' unless ENV['CI']
end


require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x']
  t.cucumber_opts += ['--format pretty']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib"
  puts "\n## Test Code Stats"
  sh "countloc -r spec"
end

require 'guard'
desc "Start up guard, does not exit until told to with 'q'."
task :guard do
  Guard.setup
  Guard::Dsl.evaluate_guardfile(:guardfile => 'Guardfile')
  Guard.start
end

# File lib/tasks/notes.rake
desc "Find notes in code"
task :notes do
  puts `grep --exclude=Rakefile -r 'OPTIMIZE:\\|FIXME:\\|TODO:\\|NOTE:' .`
end

# Clean up any artefacts
desc "Clean up dev environment cruft like tmp and packages"
task :clean do
  %w{pkg tmp}.each do |subdir|
    FileUtils.rm_rf(subdir)
  end
end
