require File.expand_path('../lib/knife-community/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'knife-community'
  gem.summary       = 'A Knife plugin to assist with deploying completed Chef cookbooks to the Chef Supermarket'
  gem.description   = 'The centralized location for sharing cookbooks is the Chef Supermarket, this is a process helper to produce a repeatable method for releasing cookbooks.'
  gem.version       = KnifeCommunity::VERSION
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'chef', '>= 10.12'

  # OPTIMIZE: Use Mixlib/Shellout until actions are written in pure ruby
  gem.add_dependency 'mixlib-shellout', '~> 1.1'

  # Using Grit to examine git repo status, and interact with a git repo
  gem.add_dependency 'grit', '~> 2.5'

  # A good version comparison library
  gem.add_dependency 'versionomy', '~> 0.4'

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_development_dependency 'aruba', '~> 0.9'
  gem.add_development_dependency 'countloc', '~> 0.4'
  gem.add_development_dependency 'cucumber', '~> 2.1'
  gem.add_development_dependency 'guard', '~> 2.13'
  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'rspec', '~> 3.3.0'
  gem.add_development_dependency 'rubocop', '~> 0.34.1'
  gem.add_development_dependency 'simplecov', '~> 0.10'

  gem.authors       = ['Mike Fiedler']
  gem.email         = ['miketheman@gmail.com']
  gem.homepage      = 'http://miketheman.github.com/knife-community'
end
