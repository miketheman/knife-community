require 'spec_helper'

# # Here we expose any proviate methods that we want tested
# # There may be other ways to do this, I'm no rspec expert
class KnifeCommunity::CommunityRelease
  public :get_tag_string
end

describe KnifeCommunity::CommunityRelease do

  describe "options" do

    before(:each) do
      @runner = KnifeCommunity::CommunityRelease.new
      @runner.name_args = ["apache2", "0.1.0"]
      @runner.setup
    end

    describe "version string handling" do
      it "should use the provided version string" do
        @runner.setup[1].to_s.should == "0.1.0"
      end
    end

    describe "version tag prefix handling" do
      it "should not prepend the tagprefix when not provided" do
        @runner.get_tag_string.should == "0.1.0"
      end
      it "should not prepend tagprefix when none specified" do
        @runner.options[:tag_prefix] = nil
        @runner.get_tag_string.should == "0.1.0"
      end
      it "should prepend the tagprefix when provided" do
        @runner.config[:tag_prefix] = "v"
        @runner.get_tag_string.should == "v0.1.0"
      end
    end

  end

end
