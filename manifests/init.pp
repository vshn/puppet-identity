# == Class: identity
#
# Full description of class identity here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
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
  $package_ensure      = $::identity::params::package_ensure,
  $package_name        = $::identity::params::package_name,
  $service_name        = $::identity::params::service_name,
  $service_enable      = $::identity::params::service_enable,
  $service_ensure      = $::identity::params::service_ensure,
  $service_manage      = $::identity::params::service_manage,
) inherits ::identity::params {

  # validate parameters here:
  # validate_absolute_path, validate_bool, validate_string, validate_hash
  # validate_array, ... (see stdlib docs)

  class { '::identity::install': } ->
  class { '::identity::config': } ~>
  class { '::identity::service': } ->
  Class['::identity']

  contain ::identity::install
  contain ::identity::config
  contain ::identity::service

}
