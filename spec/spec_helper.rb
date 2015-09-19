require 'simplecov'
SimpleCov.start

require 'rspec'
# Load any custom matchers
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

require 'knife-community'
require 'chef/knife/community_release'

CHEF_SPEC_CB_DIR = File.expand_path(File.dirname(__FILE__) + '/test-cookbooks/')

# Some test examples change behavior based on Chef version.
CHEF_12_OR_HIGHER = Versionomy.parse(Chef::VERSION).major >= 12
