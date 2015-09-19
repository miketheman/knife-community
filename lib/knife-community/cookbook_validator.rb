require 'chef/cookbook_loader'
require 'versionomy'

module KnifeCommunity
  # Looks at a cookbook
  class CookbookValidator
    attr_reader :cookbook_name, :cookbook_path, :target_version

    def initialize(cookbook_name, cookbook_path, target_version)
      @cookbook_name  = cookbook_name
      @cookbook_path  = cookbook_path
      @target_version = target_version
    end

    def validate!
      validate_cookbook_exists
      validate_target_version_is_great unless target_version.nil? # It IS great!
    end

    private

    def cookbook_loader
      @cookbook_loader ||= Chef::CookbookLoader.new(cookbook_path)
    end

    # Since we can have cookbooks in paths that are not named the same as the
    # directory, using a metadata entry to describe the cookbook is better.
    # In its absence, uses the directory name. We inherit this behavior from
    # CookbookLoader.
    #
    # @raise [CookbookNotFoundInRepo] if the cookbook cannot be found in the path
    def validate_cookbook_exists
      unless cookbook_loader.cookbook_exists?(cookbook_name)
        fail Chef::Exceptions::CookbookNotFoundInRepo,
             "Cannot find a cookbook named #{cookbook_name} at #{cookbook_path}"
      end
    end

    # @raise [InvalidCookbookVersion] if the cookbook version is equal or higher to
    #   the target version
    def validate_target_version_is_great
      cb = cookbook_loader.cookbooks_by_name[cookbook_name]

      if Versionomy.parse(cb.version) >= Versionomy.parse(target_version)
        raise Chef::Exceptions::InvalidCookbookVersion,
          "The current version, #{cb.version} is either greater or equal to the new version, #{target_version} " +
            "For your own sanity, don't release historical cookbooks into the wild."
      end
    end
  end # class CookbookValidator
end # module
