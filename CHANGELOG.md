# v0.2.0 - May 2, 2013

- Enhancement: Added a flag for `--tag-prefix` (GH-9, requested by @fnichol)
- General: started adding rspec unit tests to get better test coverage

# v0.1.1 - March 1, 2013

- BugFix: Version bumper was updating more than it should, in the case where a version string was found more than once in `metadata.rb`.

# v0.1.0 - February 26, 2013

- BugFix: Dropped a bunch older Chef versions due to a JSON dependency nightmare, passes tests
- Enhancement: Moved to a better SemVer version number, to reflect features vs patches
- Enhancement: Added mods from @schisamo, user flags for git push and share, preserves default behavior
- **NOTE**: a user prompt has been added to the community release. Use `-y` to bypass

# v0.0.1 - September 17, 2012

- Initial version, does a lot of the "heavy lifting" and accomplishes the task
