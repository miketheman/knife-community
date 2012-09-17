require 'chef/knife'

module KnifeCommunity
  class CommunityRelease < Chef::Knife

    deps do
      require 'knife-community/version'
      require 'mixlib/shellout'
      require 'chef/cookbook_loader'
      require 'grit'
      require 'versionomy'
    end

    banner "knife community release COOKBOOK [VERSION] (options)"

    option :cookbook_path,
      :short => "-o PATH:PATH",
      :long => "--cookbook-path PATH:PATH",
      :description => "A colon-separated path to look for cookbooks in",
      :proc => lambda { |o| o.split(":") }

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
      # Set variables for global use
      @cookbook = name_args.first
      @version = Versionomy.parse(name_args.last) if name_args.size > 1

      # Do a bunch of validations before we change anything
      validate_cookbook_exists
      validate_repo
      validate_repo_clean
      validate_version_sanity


      if config[:devodd]
        puts "I'm odd!"
      end

    end #run

    private

    # Ensure argumanets are valid, assign values of arguments
    #
    # @param [Array] the global `name_args` object
    def validate_args
      if name_args.size < 1
        ui.error("No cookbook has been specified")
        show_usage
        exit 1
      end
      if name_args.size > 2
        ui.error("Too many arguments are being passed. Please verify.")
        show_usage
        exit 1
      end
    end

    # Re-used from Chef
    def cookbook_loader
      @cookbook_loader ||= Chef::CookbookLoader.new(config[:cookbook_path])
    end

    # Validate cookbook existence
    # Since we can have cookbooks in paths that are not named the same as the directory, using
    # a metadata entry to describe the cookbook is better. In its absence, uses the directory name.
    #
    # @return [String] @cb_path, a string with the root directory of the cookbook
    # @return [String] @cb_name, a string with the cookbook's name, either from metadata or interpreted from directory
    def validate_cookbook_exists
      unless cookbook_loader.cookbook_exists?(@cookbook)
        ui.error "Cannot find a cookbook named #{@cookbook} at #{config[:cookbook_path]}"
        exit 2
      end
      cb = cookbook_loader.cookbooks_by_name[@cookbook]
      @cb_path = cb.root_dir
      @cb_name = cb.metadata.name.to_s
      @cb_version = Versionomy.parse(cb.version)
    end

    # Ensure that the cookbook is in a git repo
    # @todo OPTIMIZE: Use Grit instead of shelling out.
    # Couldn't figure out the rev_parse method invocation on a non-repo.
    #
    # @return [String] The absolute file path of the git repository's root
    # @example
    #  "/Users/miketheman/git/knife-community"
    def validate_repo
      begin
        proc = Mixlib::ShellOut.new("cd #{@cb_path} && git rev-parse --show-toplevel")
        proc.run_command
        proc.error!
        @repo_root = proc.stdout.chomp
      rescue Exception => e
        ui.error "There doesn't seem to be a git repo at #{@cb_path}\n#{e}"
        exit 3
      end
    end

    # Inspect the cookbook directory's git status is good to push.
    # Any existing tracked files should be staged, otherwise error & exit.
    # Untracked files are warned about, but will allow continue.
    def validate_repo_clean
      @gitrepo = Grit::Repo.new(@repo_root)
      status = @gitrepo.status
      if !status.changed.nil? or status.changed != 0 # This has to be a convoluted way to determine a non-empty...
        # Test each for the magic sha_index. Ref: https://github.com/mojombo/grit/issues/142
        status.changed.each do |file|
          case file[1].sha_index
          when "0" * 40
            ui.error "There seem to be unstaged changes in your repo. Either stash or add them."
            exit 4
          else
            ui.msg "There are modified files that have been staged, and will be included in the push."
          end
        end
      elsif status.untracked > 0
        ui.warn "There are untracked files in your repo. You might want to look into that."
      end
    end

    # Ensure that the version specified is larger than the current version
    # If a version wasn't specified on the command line, increment the current by one tiny.
    def validate_version_sanity
      if @version.nil?
        @version = @cb_version.bump(:tiny)
        ui.msg "No version was specified, the new version will be #{@version}"
      end
      if @cb_version >= @version
        ui.error "The current version, #{@cb_version} is either greater or equal to the new version, #{@version}"
        ui.error "For your own sanity, don't release historical cookbooks into the wild."
        exit 5
      end
    end

  end #class
end #module
