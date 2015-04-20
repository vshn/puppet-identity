# == Defined Type: group
#
# Manages a group
#
# === Parameters
#
# [*ensure*]
#   Default: present
#
# [*gid*]
#   Default: undef. See https://docs.puppetlabs.com/references/latest/type.html#group-attribute-gid
#
define identity::group (
  $ensure = present,
  $gid    = undef,
) {

  group { $title:
    ensure => $ensure,
    gid    => $gid,
  }

}
