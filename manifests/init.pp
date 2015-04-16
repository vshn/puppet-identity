# == Class: identity
#
# Manages identities (users and groups)
#
# === Parameters
#
# [*user_defaults*]
#   Default: {}.
#
# [*users*]
#   Default: {}.
#
# [*group_defaults*]
#   Default: {}.
#
# [*groups*]
#   Default: {}.
#
# [*manage_skel*]
#   Default: false.
#
# [*skel_source*]
#   Default: undef.
#
# [*dotfiles_source*]
#   Default: undef.
#
# === Examples
#
#  class { 'identity':
#    sample_parameter => 'sample value',
#  }
#
# === Authors
#
# Tobias Brunner
#
# === Copyright
#
# Copyright 2015 Tobias Brunner
#
class identity (
  $user_defaults   = {},
  $users           = {},
  $group_defaults  = {},
  $groups          = {},
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
