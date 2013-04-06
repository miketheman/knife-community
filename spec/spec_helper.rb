require 'rspec'
# Load any custom matchers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

require 'chef/knife/community_release'

# everything from KnifeCommunity::CommunityRelease#deps here as well
# FIXME: Why do I have to re-require everything?
require 'knife-community/version'
require 'mixlib/shellout'
require 'chef/config'
require 'chef/cookbook_loader'
require 'chef/knife/cookbook_site_share'
require 'chef/cookbook_site_streaming_uploader'
require 'grit'
require 'versionomy'
require 'json'
