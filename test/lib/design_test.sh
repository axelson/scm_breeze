#!/bin/bash
# ------------------------------------------------------------------------------
# SCM Breeze - Streamline your SCM workflow.
# Copyright 2011 Nathan Broadbent (http://madebynathan.com). All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# ------------------------------------------------------------------------------
#
# Unit tests for git shell scripts

export scmbDir="$( cd -P "$( dirname "$0" )" && pwd )/../.."

# Zsh compatibility
if [ -n "${ZSH_VERSION:-}" ]; then shell="zsh"; SHUNIT_PARENT=$0; setopt shwordsplit; fi

# Load test helpers
. "$scmbDir/test/support/test_helper"

# Load functions to test
. "$scmbDir/lib/scm_breeze.sh"
. "$scmbDir/lib/design.sh"


# Setup and tear down
#-----------------------------------------------------------------------------
oneTimeSetUp() {
  root_design_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
  project_design_dir="design"
  design_base_dirs="a b c d e"
  design_av_dirs="aa bb cc dd ee"
  design_ext_dirs="x y z"

  project_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
  project_name=$(basename $project_dir)
}

oneTimeTearDown() {
  rm -rf $project_dir $root_design_dir
}

#-----------------------------------------------------------------------------
# Unit tests
#-----------------------------------------------------------------------------

test_design() {
  cd $project_dir
  # Test creation of base and extra design directories
  design init > /dev/null
  for dir in $design_ext_dirs; do
    assertTrue "Root design dir not created! ($dir)" "[ -d $root_design_dir/$dir ]" || return
  done
  for dir in $design_base_dirs; do
    assertTrue "Root design dir not created! ($dir)" "[ -d $root_design_dir/$dir/$project_name ]" || return
    assertTrue "Project design dir not created! ($dir)" "[ -d $project_dir/design/$dir ]" || return
  done

  # Test creation of 'av' design directories
  design init --av > /dev/null
  for dir in $design_base_dirs $design_av_dirs; do
    assertTrue "Root design dir not created! ($dir)" "[ -d $root_design_dir/$dir/$project_name ]" || return
    assertTrue "Project design dir not created! ($dir)" "[ -d $project_dir/design/$dir ]" || return
  done

  # Test that 'design trim' removes empty directories, but doesn't touch non-empty directories
  touch design/a/testfile design/c/testfile
  design trim > /dev/null
  assertTrue  "[ -d $project_dir/design/a ] && [ -d $root_design_dir/a/$project_name ]"
  assertFalse "[ -d $project_dir/design/b ] || [ -d $root_design_dir/b/$project_name ]"
  assertTrue  "[ -d $project_dir/design/c ] && [ -d $root_design_dir/c/$project_name ]"
  assertFalse "[ -d $project_dir/design/d ] || [ -d $root_design_dir/d/$project_name ]"
  assertFalse "[ -d $project_dir/design/e ] || [ -d $root_design_dir/e/$project_name ]"

  # Test that 'design rm' removes all directories
  touch design/a/testfile design/c/testfile
  design rm > /dev/null
  assertFalse "[ -d $project_dir/design/a ] || [ -d $root_design_dir/a/$project_name ]"
  assertFalse "[ -d $project_dir/design/b ] || [ -d $root_design_dir/b/$project_name ]"
  assertFalse "[ -d $project_dir/design/c ] || [ -d $root_design_dir/c/$project_name ]"
  assertFalse "[ -d $project_dir/design/d ] || [ -d $root_design_dir/d/$project_name ]"
  assertFalse "[ -d $project_dir/design/e ] || [ -d $root_design_dir/e/$project_name ]"
}


# load and run shUnit2
# Call this function to run tests
. "$scmbDir/test/support/shunit2"
