# == Class identity::params
#
# This class is meant to be called from identity.
# It sets variables according to platform.
#
class identity::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'identity'
      $service_name = 'identity'
    }
    'RedHat', 'Amazon': {
      $package_name = 'identity'
      $service_name = 'identity'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # package parameters
  $package_ensure = installed

  # service parameters
  $service_enable = true
  $service_ensure = running
  $service_manage = true

}
