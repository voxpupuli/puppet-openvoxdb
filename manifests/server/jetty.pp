# @summary configures puppetdb jetty ini
#
# @api private
class openvoxdb::server::jetty (
  Stdlib::Host $listen_address                = $openvoxdb::params::listen_address,
  Stdlib::Port::Unprivileged $listen_port     = $openvoxdb::params::listen_port,
  Boolean $disable_cleartext                  = $openvoxdb::params::disable_cleartext,
  Stdlib::Host $ssl_listen_address            = $openvoxdb::params::ssl_listen_address,
  Stdlib::Port::Unprivileged $ssl_listen_port = $openvoxdb::params::ssl_listen_port,
  Boolean $disable_ssl                        = $openvoxdb::params::disable_ssl,
  Boolean $ssl_set_cert_paths                 = $openvoxdb::params::ssl_set_cert_paths,
  Stdlib::Unixpath $ssl_cert_path             = $openvoxdb::params::ssl_cert_path,
  Stdlib::Unixpath $ssl_key_path              = $openvoxdb::params::ssl_key_path,
  Stdlib::Unixpath $ssl_ca_cert_path          = $openvoxdb::params::ssl_ca_cert_path,
  Optional[String] $ssl_protocols             = $openvoxdb::params::ssl_protocols,
  Optional[String] $cipher_suites             = $openvoxdb::params::cipher_suites,
  Stdlib::Unixpath $confdir                   = $openvoxdb::params::confdir,
  Optional[Integer] $max_threads              = $openvoxdb::params::max_threads,
  String[1] $puppetdb_group                   = $openvoxdb::params::puppetdb_group,
) inherits openvoxdb::params {
  $jetty_ini = "${confdir}/jetty.ini"

  file { $jetty_ini:
    ensure => file,
    owner  => 'root',
    group  => $puppetdb_group,
    mode   => '0640',
  }

  # Set the defaults
  Ini_setting {
    path    => $jetty_ini,
    ensure  => present,
    section => 'jetty',
    require => File[$jetty_ini],
  }

  $cleartext_setting_ensure = $disable_cleartext ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_host':
    ensure  => $cleartext_setting_ensure,
    setting => 'host',
    value   => $listen_address,
  }

  ini_setting { 'puppetdb_port':
    ensure  => $cleartext_setting_ensure,
    setting => 'port',
    value   => $listen_port,
  }

  $ssl_setting_ensure = $disable_ssl ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_sslhost':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-host',
    value   => $ssl_listen_address,
  }

  ini_setting { 'puppetdb_sslport':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-port',
    value   => $ssl_listen_port,
  }

  if $ssl_protocols {
    ini_setting { 'puppetdb_sslprotocols':
      ensure  => $ssl_setting_ensure,
      setting => 'ssl-protocols',
      value   => $ssl_protocols,
    }
  }

  if $cipher_suites {
    ini_setting { 'puppetdb_cipher-suites':
      ensure  => $ssl_setting_ensure,
      setting => 'cipher-suites',
      value   => $cipher_suites,
    }
  }

  if $ssl_set_cert_paths {
    # assume paths have been validated in calling class
    ini_setting { 'puppetdb_ssl_key':
      ensure  => present,
      setting => 'ssl-key',
      value   => $ssl_key_path,
    }
    ini_setting { 'puppetdb_ssl_cert':
      ensure  => present,
      setting => 'ssl-cert',
      value   => $ssl_cert_path,
    }
    ini_setting { 'puppetdb_ssl_ca_cert':
      ensure  => present,
      setting => 'ssl-ca-cert',
      value   => $ssl_ca_cert_path,
    }
  }

  if ($max_threads) {
    ini_setting { 'puppetdb_max_threads':
      setting => 'max-threads',
      value   => $max_threads,
    }
  } else {
    ini_setting { 'puppetdb_max_threads':
      ensure  => absent,
      setting => 'max-threads',
    }
  }
}
