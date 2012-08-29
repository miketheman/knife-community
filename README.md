knife-community
===============

A Knife plugin to assist with deploying completed Chef cookbooks to the Community Site

Intro
-----

There are sooo many ways to [deliver software][wiki:apppkg].
Apt has 'deb', Yum has 'rpm', Node has 'npm', RubyGems has 'gem', Java has 'jar', etc etc etc.

In The Land of [Chef][chef], the typical unit of shareable software is a 'cookbook'.

The centralized location for sharing cookbooks is the [Community Site][opcs], and we already have support to download/install these elements, either it be through [knife itself][kcsi], [librarian][libr], and [berkshelf][brks], and there are probably others.

What we _don't_ have is a good method for cookbook maintainers to contribute back to the Community Site, while semi-enforcing good habits, such as version incrementing, git tags and forming the package correctly.

Assumptions
-----------

### Basics
* You know what Git is
* You know what Chef is
* You have Push permissions to the remote GitHub repository
* You don't already have a perfected workflow that works for you
* You want to be a helpful citizen of the community

### Important
* You have **not** incremented the version number in `metadata.rb` - this will do so for you
* You have a `name` string defined in your `metadata.rb`, OR your repository name is identical to your cookbook name


Cookbook Release Workflow
-------------------------

Assuming you have made your changes, tested your code thoroughly (one can hope!), all merged into your `master` branch, and are ready to release a new version of your cookbook, here's a flow to follow:

1. Ensure that the branch is 'clean' - no outstanding uncommitted changes
1. Read in the current `metadata.rb`, inspect the `version` string, and increment it to the next minor version. Override with `--ver`
1. Create a git commit for the `metadata.rb` change.
1. Create a git tag with the version number (no leading "v" or the like)
1. Push all commits/tags to the set remote, typically like `git push origin master`. Override with `--branch`
1. Create a 'package' - effectively a compressed tarball - and upload it to the community site
1. Have a beer, or glass of wine - you choose.

This flow can probably be used for most cookbook maintainers.

Usage
=====

Invoke
------

    knife community release COOKBOOK [ --ver=X.Y.Z | --remote=origin | --branch=master | --devodd ]

Flags
-----

* `--ver=VER` - String, Version in X.Y.Z format. Manually specify the version.

    If unspecified, increments to the next x.y.Z version (`--version` is already defined in knife)

* `--remote=REMOTE` - String, Remote repository to push to. Defaults to `origin`

* `--branch=BRANCHNAME` - String, Branch name. Defaults to `master`

* `--devodd` - Boolean. If specified, post-release, will bump the minor version to the next odd number, and generate another commit & push (but no tags).

    This is a flow that some adopt by having even-only numbered releases, utilizing the [odd numbered ones for development][wiki:oddver].


Some good ideas while working on a cookbook
-------------------------------------------

Creating a `CHANGELOG.md` that details a short message about any changes included in each release is really helpful to anyone looking at your updated cookbook and seeing if it addresses a problem they have, without delving deeper into the code.

Updating a `TODO.md` file if there are outstanding known issues, planned work for the next version, etc. A TODO file also helps anyone else in the community try to tackle a problem you haven't figured out or gotten to yet, so they can issue a pull request for your cookbook.

Follow [Semantic Versioning][semver] when choosing which version number to increment to. Start your cookbook at 0.1.0, and increment from there, until you are confident enough in a 1.0.0 version. This should be done with `--ver=1.0.0`, for example.

Test, test, test. And then test again.


[brks]: http://berkshelf.com/
[chef]: http://www.opscode.com/chef/
[kcsi]: http://wiki.opscode.com/display/chef/Managing+Cookbooks+With+Knife#ManagingCookbooksWithKnife-CookbookSite
[libr]: https://github.com/applicationsonline/librarian
[opcs]: http://community.opscode.com/
[semver]: http://semver.org/
[wiki:apppkg]: http://en.wikipedia.org/wiki/List_of_software_package_management_systems#Application-level_package_managers
[wiki:oddver]: http://en.wikipedia.org/wiki/Software_versioning#Odd-numbered_versions_for_development_releases
