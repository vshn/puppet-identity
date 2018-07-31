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
#   Default: false. When true, a user with an empty password will have a `*`
#   set as password instead of a `!`. This is especially handy if you want to
#   disable UsePAM for SSH. `!` is a locked account and without UsePAM the user
#   can't login anymore with key-based authentication.
#
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
  Hash[Any, Any] $user_defaults = {},
  Hash[Any, Any] $users = {},
  Hash[Any, Any] $group_defaults = {},
  Hash[Any, Any] $groups = {},
  String $hiera_user_defaults_key = 'user_defaults',
  String $hiera_users_key = 'users',
  Stirng $hiera_group_defaults_key = 'group_defaults',
  String $hiera_groups_key = 'groups',
  Boolean $manage_users = true,
  Boolean $manage_groups = true,
  boolean $manage_skel = false,
  Optional[String] $skel_source = undef,
  Optional[String] $dotfiles_source = undef,
  Boolean $emptypassword_policy = false,
) {
  # User handling
  if $manage_users {
    # check if $users parameter contains data
    if ! empty($users) {
      $_users = $users
    } else {
      $_users = hiera_hash($hiera_users_key,{})
    }

    # check if $user_defaults parameter contains data
    if ! empty($user_defaults) {
      $_user_defaults = $user_defaults
    } else {
      $_user_defaults = hiera_hash($hiera_user_defaults_key, {})
    }

    create_resources('::identity::user', $_users, merge({
      'emptypassword_policy' => $emptypassword_policy,
      }, $_user_defaults))
  }

  # Group handling
  if $manage_groups {
    # check if $groups parameter contains data
    if ! empty($groups) {
      $_groups = $groups
    } else {
      $_groups = hiera_hash($hiera_groups_key,{})
    }
    # check if $group_defaults parameter contains data
    if ! empty($group_defaults) {
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
