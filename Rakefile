#!/usr/bin/env rake
require "bundler/gem_tasks"

task :default => [:features]

# https://github.com/turboladen/tailor
require 'tailor/rake_task'
Tailor::RakeTask.new do |task|
  task.file_set('lib/**/*.rb', 'code') do |style|
    style.max_line_length 100, level: :warn
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x']
  t.cucumber_opts += ['--format pretty']
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
