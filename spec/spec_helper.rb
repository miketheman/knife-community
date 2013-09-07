require 'rspec'
# Load any custom matchers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

require 'knife-community'
require 'chef/knife/community_release'

CHEF_SPEC_CB_DIR = File.expand_path(File.dirname(__FILE__) + "/test-cookbooks/")
