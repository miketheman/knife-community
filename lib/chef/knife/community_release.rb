require 'chef/knife'

module KnifeCommunity
  class CommunityRelease < Chef::Knife

    deps do
      require 'knife-community/version'
    end

    banner "knife community release COOKBOOK [VERSION] (options)"

    option :remote,
      :short => "-R REMOTE",
      :long => "--remote REMOTE",
      :default => "origin",
      :description => "Remote Git repository to push to"

    option :branch,
      :short => "-B ",
      :long => "--branch BRANCH",
      :default => "master",
      :description => "Remote Git branch name to push to"

    option :devodd,
      :long => "--devodd",
      :boolean => true,
      :description => "Odd-numbered development cycle. Bump minor version & commit for development"

    def run
      validate_args

      cookbook = name_args.first
      version = name_args.last if name_args.size > 1

      if config[:devodd]
        puts "I'm odd!"
      end

    end #run

    private

    def validate_args
      if name_args.size < 1
        ui.error("No cookbook has been specified")
        show_usage
        exit 1
      end
      if name_args.size > 2
        ui.error("Too many parameters are being passed.")
        show_usage
        exit 1
      end
    end #validate_args

  end #class
end #module
