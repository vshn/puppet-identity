# == Class: identity
#
# Manages identities (users and groups)
#
# === Parameters
#
# [*user_defaults*]
#   Default: {} (hiera_hash).
#   Defaults to apply to all users created with the users hash.
#
# [*users*]
#   Default: {} (hiera_hash).
#   Hash of users to pass to the user defined type.
#
# [*group_defaults*]
#   Default: {} (hiera_hash).
#   Defaults to apply to all groups created with the groups hash.
#
# [*groups*]
#   Default: {} (hiera_hash).
#   Hash of groups to pass to the group defined type.
#
# [*manage_skel*]
#   Default: false.
#   Should the directory /etc/skel being managed by this class.
#
# [*skel_source*]
#   Default: undef.
#   Source of the /etc/skel directory if it is managed.
#   Example: 'puppet:///modules/identity_data/skel'
#
# [*dotfiles_source*]
#   Default: undef.
#   Source of the user specific dotfiles directory.
#   Example: 'puppet:///modules/identity_data'
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
  $user_defaults   = hiera_hash('identity::user_defaults',{}),
  $users           = hiera_hash('identity::users',{}),
  $group_defaults  = hiera_hash('identity::group_defaults',{}),
  $groups          = hiera_hash('identity::groups',{}),
  $manage_skel     = false,
  $skel_source     = undef,
  $dotfiles_source = undef,
) {

  validate_hash($user_defaults)
  validate_hash($users)
  validate_hash($group_defaults)
  validate_hash($groups)

  if $users {
    create_resources('identity::user',$users,$user_defaults)
  }
  if $groups {
    create_resources('identity::group',$groups,$group_defaults)
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
