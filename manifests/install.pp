# == Class identity::install
#
# This class is called from identity for install.
#
class identity::install inherits identity {

  package { $package_name:
    ensure => $package_ensure,
  }
}
