#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/clean'
require 'rubocop/rake_task'

CLEAN.include %w(coverage/ pkg/ tmp/)
CLOBBER.include %w(doc/ Gemfile.lock)

task default: [:style, :spec, :features]

RuboCop::RakeTask.new(:style)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w( features -x )
  t.cucumber_opts += ['--format progress']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Display LOC stats'
task :stats do
  puts '\n## Production Code Stats'
  sh 'countloc -r lib'
  puts '\n## Test Code Stats'
  sh 'countloc -r spec'
end

require 'guard'
desc 'Start up guard, does not exit until told to with "q".'
task :guard do
  Guard.setup
  Guard::Dsl.evaluate_guardfile(guardfile: 'Guardfile')
  Guard.start
end

# File lib/tasks/notes.rake
desc 'Find notes in code'
task :notes do
  puts `grep --exclude=Rakefile -r 'OPTIMIZE:\\|FIXME:\\|TODO:\\|NOTE:' .`
end
