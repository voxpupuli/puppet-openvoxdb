# @summary manage the installation of the report processor on the primary
#
# @api private
class openvoxdb::master::report_processor (
  $puppet_conf = $openvoxdb::params::puppet_conf,
  $masterless  = $openvoxdb::params::masterless,
  $enable      = false
) inherits openvoxdb::params {
  $puppet_conf_section = if $masterless {
    'main'
  } else {
    'server'
  }

  $puppetdb_ensure = $enable ? {
    true    => present,
    default => absent,
  }

  ini_subsetting { 'puppet.conf/reports/puppetdb':
    ensure               => $puppetdb_ensure,
    path                 => $puppet_conf,
    section              => $puppet_conf_section,
    setting              => 'reports',
    subsetting           => 'puppetdb',
    subsetting_separator => ',',
  }
}
