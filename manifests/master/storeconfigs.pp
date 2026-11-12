# @summary configure the puppet master to enable storeconfigs and to use puppetdb as the storeconfigs backend
#
# @api private
class openvoxdb::master::storeconfigs (
  Stdlib::Absolutepath $puppet_conf = $openvoxdb::params::puppet_conf,
  Boolean $masterless               = $openvoxdb::params::masterless,
  Boolean $enable                   = true,
) inherits openvoxdb::params {
  $puppet_conf_section = if $masterless {
    'main'
  } else {
    'server'
  }

  $storeconfigs_ensure = $enable ? {
    true    => present,
    default => absent,
  }

  Ini_setting {
    section => $puppet_conf_section,
    path    => $puppet_conf,
    ensure  => $storeconfigs_ensure,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs":
    setting => 'storeconfigs',
    value   => true,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs_backend":
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }
}
