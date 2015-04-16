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
