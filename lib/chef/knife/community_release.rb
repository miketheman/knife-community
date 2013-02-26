require 'chef/knife'

module KnifeCommunity
  class CommunityRelease < Chef::Knife

    deps do
      require 'knife-community/version'
      require 'mixlib/shellout'
      require 'chef/config'
      require 'chef/cookbook_loader'
      require 'chef/knife/cookbook_site_share'
      require 'chef/cookbook_site_streaming_uploader'
      require 'grit'
      require 'versionomy'
      require 'json'
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

    option :git_push,
      :long => "--[no-]git-push",
      :boolean => true,
      :default => true,
      :description => "Indicates whether the commits and tags should be pushed to pushed to the default git remote."

    option :site_share,
      :long => "--[no-]site-share",
      :boolean => true,
      :default => true,
      :description => "Indicates whether the cookbook should be pushed to the community site."

    def run
      self.config = Chef::Config.merge!(config)
      validate_args
      # Set variables for global use
      @cookbook = name_args.first
      @version = Versionomy.parse(name_args.last) if name_args.size > 1

      ui.msg "Starting to validate the envrionment before changing anything..."
      validate_cookbook_exists
      validate_repo
      validate_repo_clean
      validate_version_sanity
      validate_no_existing_tag
      validate_target_remote_branch

      ui.msg "All validation steps have passed, making changes..."
      set_new_cb_version
      commit_new_cb_version
      tag_new_cb_version

      if config[:git_push]
        git_push_commits
        git_push_tags
      end

      if config[:site_share]
        confirm_share_msg  = "Shall I release version #{@version} of the"
        confirm_share_msg << " #{@cb_name} cookbook to the community site? (Y/N) "
        if config[:yes] || (ask_question(confirm_share_msg).chomp.upcase == "Y")
          share_new_version
          ui.msg "Version #{@version} of the #{@cb_name} cookbook has been released!"
          ui.msg "Check it out at http://ckbk.it/#{@cb_name}"
        end
      end

      # @TODO: Increment the current version to the next available odd number
      # algo = n + 1 + (n % 2)
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
    # @TODO: Use Grit instead of shelling out.
    # Couldn't figure out the rev_parse method invocation on a non-repo.
    #
    # @return [String] The absolute file path of the git repository's root
    # @example
    #  "/Users/miketheman/git/knife-community"
    def validate_repo
      begin
        @repo_root = shellout("git rev-parse --show-toplevel").stdout.chomp
      rescue Exception => e
        ui.error "There doesn't seem to be a git repo at #{@cb_path}\n#{e}"
        exit 3
      end
    end

    # Inspect the cookbook directory's git status is good to push.
    # Any existing tracked files should be staged, otherwise error & exit.
    # Untracked files are warned about, but will allow continue.
    # This needs more testing.
    def validate_repo_clean
      @gitrepo = Grit::Repo.new(@repo_root)
      status = @gitrepo.status
      if !status.changed.nil? or status.changed.size != 0 # This has to be a convoluted way to determine a non-empty...
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
      elsif status.untracked.size > 0
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

    # Ensure that there isn't already a git tag for this version.
    def validate_no_existing_tag
      existing_tags = Array.new
      @gitrepo.tags.each { |tag| existing_tags << tag.name }
      if existing_tags.include?(@version.to_s)
        ui.error "This version tag has already been committed to the repo."
        ui.error "Are you sure you haven't released this already?"
        exit 6
      end
    end

    # Ensure that the remote and branch are indeed valid. We provide defaults in options.
    def validate_target_remote_branch
      remote_path = File.join(config[:remote], config[:branch])

      remotes = Array.new
      @gitrepo.remotes.each { |remote| remotes << remote.name }
      unless remotes.include?(remote_path)
        ui.error "The remote/branch specified does not seem to exist."
        exit 7
      end
    end

    # Replace the existing version string with the new version
    def set_new_cb_version
      metadata_file = File.join(@cb_path, "metadata.rb")
      fi = File.read(metadata_file)
      fi.gsub!(@cb_version.to_s, @version.to_s)
      fo = File.open(metadata_file, 'w') { |file| file.puts fi }
    end

    # Using shellout as needed.
    # @todo Struggled with the Grit::Repo#add for hours.
    def commit_new_cb_version
      shellout("git add metadata.rb")
      @gitrepo.commit_index("release v#{@version}")
    end

    def tag_new_cb_version
      shellout("git tag -a -m 'release v#{@version}' #{@version}")
    end

    # Apparently Grit does not have any `push` semantics yet.
    def git_push_commits
      shellout("git push #{config[:remote]} #{config[:branch]}")
    end

    def git_push_tags
      shellout("git push #{config[:remote]} --tags")
    end

    def share_new_version
      # Need to find the existing cookbook's category. Thankfully, this is readily available via REST/JSON.
      response = Net::HTTP.get_response("cookbooks.opscode.com", "/api/v1/cookbooks/#{@cb_name}")
      category = JSON.parse(response.body)['category'] ||= "Other"

      cb_share = Chef::Knife::CookbookSiteShare.new
      cb_share.name_args = [@cb_name, category]
      cb_share.run
    end

    def shellout(command)
      proc = Mixlib::ShellOut.new(command, :cwd => @cb_path)
      proc.run_command
      proc.error!
      return proc
    end

  end #class
end #module
