# -*- encoding: utf-8 -*-
require File.expand_path('../lib/knife-community/version', __FILE__)

Gem::Specification.new do |gem|

  gem.name          = "knife-community"
  gem.summary       = %q{A Knife plugin to assist with deploying completed Chef cookbooks to the Community Site}
  gem.description   = %q{The centralized location for sharing cookbooks is the Community Site, this is a process helper to produce a repeatable method for releasing cookbooks.}
  gem.version       = KnifeCommunity::VERSION
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'chef', '>= 10.12'

  # OPTIMIZE: Use Mixlib/Shellout until actions are written in pure ruby
  gem.add_dependency 'mixlib-shellout', '~> 1.1'

  # Using Grit to examine git repo status, and interact with a git repo
  gem.add_dependency 'grit', '~> 2'

  # A good version comparison library
  gem.add_dependency 'versionomy', '~> 0.4'

  gem.required_ruby_version = '>= 1.9.2'

  gem.add_development_dependency 'aruba', '~> 0.4'
  gem.add_development_dependency 'cane', '~> 2.5'
  gem.add_development_dependency 'countloc', '~> 0.4'
  gem.add_development_dependency 'cucumber', '~> 1'
  gem.add_development_dependency 'guard', '~> 1.6'
  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'tailor', '~> 1.2'

  gem.authors       = ["Mike Fiedler"]
  gem.email         = ["miketheman@gmail.com"]
  gem.homepage      = "http://miketheman.github.com/knife-community"

end
