Feature: Ensure that the Command Line Interface works as designed
  In order to operate the knife community release cookbook tool
  As a Cookbook Maintainer
  I want to ensure the CLI behaves correctly with different arguments

Scenario: Running with no arguments produces a failure
  When I run `knife community release`
  Then the exit status should be 1

Scenario: Running with too many arguments produces a failure
  When I run `knife community release foo bar baz`
  Then the exit status should be 1
