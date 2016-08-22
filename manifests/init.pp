# == Class: identity
#
# Manages identities (users and groups)
#
# === Parameters
#
# [*user_defaults*]
#   Default: {}
#   Defaults to apply to all users created with the users hash.
#
# [*users*]
#   Default: {}
#   Hash of users to pass to the user defined type.
#
# [*group_defaults*]
#   Default: {}
#   Defaults to apply to all groups created with the groups hash.
#
# [*groups*]
#   Default: {}
#   Hash of groups to pass to the group defined type.
#
# [*hiera_user_defaults_key*]
#   Default: user_defaults
#   String to be used as Hiera lookup key for user_defaults used by create_resources
#
# [*hiera_users_key*]
#   Default: users
#   String to be used as Hiera lookup key for users used by create_resources
#
# [*hiera_group_defaults_key*]
#   Default: group_defaults
#   String to be used as Hiera lookup key for group_defaults used by create_resources
#
# [*hiera_groups_key*]
#   Default: groups
#   String to be used as Hiera lookup key for groups used by create_resources
#
# [*manage_users*]
#   Default: true
#   Manage the users using create_resources
#
# [*manage_groups*]
#   Default: true
#   Manage the groups using create_resources
#
# [*manage_skel*]
#   Default: false
#   Should the directory /etc/skel being managed by this class.
#
# [*skel_source*]
#   Default: undef
#   Source of the /etc/skel directory if it is managed.
#   Example: 'puppet:///modules/identity_data/skel'
#
# [*dotfiles_source*]
#   Default: undef
#   Source of the user specific dotfiles directory.
#   Example: 'puppet:///modules/identity_data'
#
# [*emptypassword_policy*]
#   Default: false. When true, a user with an empty password will have a `*` set as password instead of
#   a `!` This is especially handy if you want to disable UsePAM on SSH. `!` is a locked account and without UsePAM
#   the user can't login anymore with keybased authentication.

# === Examples
#
#  class { 'identity':
#    manage_skel => true,
#    skel_source => 'puppet:///modules/identity_data/skel',
#  }
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
class identity (
  $user_defaults = {},
  $users = {},
  $group_defaults = {},
  $groups = {},
  $hiera_user_defaults_key = 'user_defaults',
  $hiera_users_key = 'users',
  $hiera_group_defaults_key = 'group_defaults',
  $hiera_groups_key = 'groups',
  $manage_users = true,
  $manage_groups = true,
  $manage_skel = false,
  $skel_source = undef,
  $dotfiles_source = undef,
  $emptypassword_policy = false,
) {

  # User handling
  if $manage_users {
    # check if $users parameter contains data
    if ! empty($users) {
      validate_hash($users)
      $_users = $users
    } else {
      $_users = hiera_hash($hiera_users_key,{})
    }

    # check if $emptypassword_policy is validate_bool
    validate_bool($emptypassword_policy)
    if $emptypassword_policy {
      $_emptypassword_policy = { "emptypassword_policy" => true}
    } else {
      $_emptypassword_policy = { "emptypassword_policy" => false}
    }

    # check if $user_defaults parameter contains data
    if ! empty($user_defaults) {
      validate_hash($user_defaults)
      $_user_defaults = merge($user_defaults, $_emptypassword_policy)
    } else {
      $_user_defaults = merge(hiera_hash($hiera_user_defaults_key,{}), $_emptypassword_policy)
    }
    create_resources('identity::user',$_users,$_user_defaults)
  }

  # Group handling
  if $manage_groups {
    # check if $groups parameter contains data
    if ! empty($groups) {
      validate_hash($groups)
      $_groups = $groups
    } else {
      $_groups = hiera_hash($hiera_groups_key,{})
    }
    # check if $group_defaults parameter contains data
    if ! empty($group_defaults) {
      validate_hash($group_defaults)
      $_group_defaults = $group_defaults
    } else {
      $_group_defaults = hiera_hash($hiera_group_defaults_key,{})
    }
    create_resources('identity::group',$_groups,$_group_defaults)
  }

  if $manage_skel {
    # deliver files into /etc/skel
    file { '/etc/skel':
      ensure  => directory,
      source  => $skel_source,
      recurse => true,
      purge   => true,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

}
