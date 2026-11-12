# @summary manage puppetdb ini
#
# @api private
class openvoxdb::server::puppetdb (
  Stdlib::Unixpath $certificate_whitelist_file = $openvoxdb::params::certificate_whitelist_file,
  Array $certificate_whitelist                 = $openvoxdb::params::certificate_whitelist,
  Optional[Boolean] $disable_update_checking   = $openvoxdb::params::disable_update_checking,
  Stdlib::Unixpath $confdir                    = $openvoxdb::params::confdir,
  String[1] $puppetdb_group                    = $openvoxdb::params::puppetdb_group,
) inherits openvoxdb::params {
  $puppetdb_ini = "${confdir}/puppetdb.ini"

  file { $puppetdb_ini:
    ensure => file,
    owner  => 'root',
    group  => $puppetdb_group,
    mode   => '0640',
  }

  # Set the defaults
  Ini_setting {
    path    => $puppetdb_ini,
    ensure  => present,
    section => 'puppetdb',
    require => File[$puppetdb_ini],
  }

  $certificate_whitelist_setting_ensure = empty($certificate_whitelist) ? {
    true    => 'absent',
    default => 'present',
  }

  # accept connections only from puppet master
  ini_setting { 'puppetdb-connections-from-master-only':
    ensure  => $certificate_whitelist_setting_ensure,
    section => 'puppetdb',
    setting => 'certificate-whitelist',
    value   => $certificate_whitelist_file,
  }

  file { $certificate_whitelist_file:
    ensure  => $certificate_whitelist_setting_ensure,
    content => template('openvoxdb/certificate-whitelist.erb'),
    mode    => '0644',
    owner   => 0,
    group   => 0,
  }

  if $disable_update_checking {
    ini_setting { 'puppetdb_disable_update_checking':
      setting => 'disable-update-checking',
      value   => $disable_update_checking,
    }
  } else {
    ini_setting { 'puppetdb_disable_update_checking':
      ensure  => 'absent',
      setting => 'disable-update-checking',
    }
  }
}
