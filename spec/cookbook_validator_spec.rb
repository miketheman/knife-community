require 'spec_helper'

describe KnifeCommunity::CookbookValidator do

  before(:all) do
    @repo_paths = [File.expand_path(CHEF_SPEC_CB_DIR)]
    @cookbook_loader = Chef::CookbookLoader.new(@repo_paths)
    @cookbook_name = "maf-test1"
  end

  describe "#initialize" do
    cookbook_path = @repo_paths
    target_version = "0.1.1"

    it "initializes the correct cookbook name with all arguments" do
      cv = KnifeCommunity::CookbookValidator.new(
        @cookbook_name, cookbook_path, target_version
      )
      expect(cv.cookbook_name).to eq @cookbook_name
    end

    it "fails when not all arguments have been passed" do
      expect {
        KnifeCommunity::CookbookValidator.new(@cookbook_name, cookbook_path)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#validate!" do
    it "returns an error when specifying existing version" do
      cv = KnifeCommunity::CookbookValidator.new(
        @cookbook_name, @repo_paths, "0.1.1"
      )

      expect {
        cv.validate!
      }.to raise_error(Chef::Exceptions::InvalidCookbookVersion)
    end

    it "passes when providing a newer version" do
      cv = KnifeCommunity::CookbookValidator.new(
        @cookbook_name, @repo_paths, "0.1.2"
      )

      expect { cv.validate! }.to_not raise_error
    end

    it "passes on a cookbook with no name in metadata.rb" do
      cv = KnifeCommunity::CookbookValidator.new(
        "maf-test2", @repo_paths, "0.2.1"
      )

      expect { cv.validate! }.to_not raise_error
    end

    it "returns an error when specifying a non-existing cookbook" do
      cv = KnifeCommunity::CookbookValidator.new(
        "ghost_cookbook", @repo_paths, "0.1.2"
      )

      expect {
        cv.validate!
      }.to raise_error(Chef::Exceptions::CookbookNotFoundInRepo)
    end
  end

end
