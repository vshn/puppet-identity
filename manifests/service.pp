# == Class identity::service
#
# This class is meant to be called from identity.
# It ensure the service is running.
#
class identity::service inherits identity {

  if $service_manage {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
