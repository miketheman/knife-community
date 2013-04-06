#!/usr/bin/env rake
require "bundler/gem_tasks"

task :default => [:spec, :features, :tailor]

# https://github.com/turboladen/tailor
require 'tailor/rake_task'
Tailor::RakeTask.new do |task|
  task.file_set 'lib/**/*.rb', :code do |style|
    style.max_line_length 160, level: :warn
    style.max_code_lines_in_method 40, level: :warn
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x']
  t.cucumber_opts += ['--format pretty']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end

# https://github.com/guard/guard
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
  puts `grep --exclude=Rakefile -r 'OPTIMIZE:\\|FIXME:\\|TODO:' .`
end

# Clean up any artefacts
desc "Clean up dev environment cruft like tmp and packages"
task :clean do
  %w{pkg tmp}.each do |subdir|
    FileUtils.rm_rf(subdir)
  end
end
