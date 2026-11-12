# @summary manage puppetdb database ini
#
# @api private
class openvoxdb::server::database (
  Stdlib::Host $database_host                                      = $openvoxdb::params::database_host,
  Stdlib::Port::Unprivileged $database_port                        = $openvoxdb::params::database_port,
  String[1] $database_username                                     = $openvoxdb::params::database_username,
  Variant[String[1], Sensitive[String[1]]] $database_password      = $openvoxdb::params::database_password,
  String[1] $database_name                                         = $openvoxdb::params::database_name,
  Boolean $manage_db_password                                      = $openvoxdb::params::manage_db_password,
  Optional[String] $jdbc_ssl_properties                            = $openvoxdb::params::jdbc_ssl_properties,
  Boolean $database_validate                                       = $openvoxdb::params::database_validate,
  String[1] $node_ttl                                              = $openvoxdb::params::node_ttl,
  String[1] $node_purge_ttl                                        = $openvoxdb::params::node_purge_ttl,
  String[1] $report_ttl                                            = $openvoxdb::params::report_ttl,
  Optional[Array] $facts_blacklist                                 = $openvoxdb::params::facts_blacklist,
  Integer $gc_interval                                             = $openvoxdb::params::gc_interval,
  Integer $node_purge_gc_batch_limit                               = $openvoxdb::params::node_purge_gc_batch_limit,
  Integer $conn_max_age                                            = $openvoxdb::params::conn_max_age,
  Integer $conn_lifetime                                           = $openvoxdb::params::conn_lifetime,
  Stdlib::Unixpath $confdir                                        = $openvoxdb::params::confdir,
  String[1] $puppetdb_group                                        = $openvoxdb::params::puppetdb_group,
  Optional[Variant[String[1], Integer[1]]] $database_max_pool_size = $openvoxdb::params::database_max_pool_size,
  Boolean $migrate                                                 = $openvoxdb::params::migrate,
  Boolean $postgresql_ssl_on                                       = $openvoxdb::params::postgresql_ssl_on,
  Stdlib::Unixpath $ssl_cert_path                                  = $openvoxdb::params::ssl_cert_path,
  Stdlib::Unixpath $ssl_key_pk8_path                               = $openvoxdb::params::ssl_key_pk8_path,
  Stdlib::Unixpath $ssl_ca_cert_path                               = $openvoxdb::params::ssl_ca_cert_path
) inherits openvoxdb::params {
  if str2bool($database_validate) {
    # Validate the database connection.  If we can't connect, we want to fail
    # and skip the rest of the configuration, so that we don't leave puppetdb
    # in a broken state.
    #
    # NOTE:
    # Because of a limitation in the postgres module this will break with
    # a duplicate declaration if read and write database host+name are the
    # same.
    class { 'openvoxdb::server::validate_db':
      database_host     => $database_host,
      database_port     => $database_port,
      database_username => $database_username,
      database_password => $database_password,
      database_name     => $database_name,
    }
  }

  $database_ini = "${confdir}/database.ini"

  file { $database_ini:
    ensure => file,
    owner  => 'root',
    group  => $puppetdb_group,
    mode   => '0640',
  }

  $file_require = File[$database_ini]
  $ini_setting_require = str2bool($database_validate) ? {
    false   => $file_require,
    default => [$file_require, Class['openvoxdb::server::validate_db']],
  }
  # Set the defaults
  Ini_setting {
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    require => $ini_setting_require,
  }

  if !empty($jdbc_ssl_properties) {
    $database_suffix = $jdbc_ssl_properties
  }
  else {
    $database_suffix = ''
  }

  $subname_default = "//${database_host}:${database_port}/${database_name}${database_suffix}"

  if $postgresql_ssl_on and !empty($jdbc_ssl_properties) {
    fail("Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!")
  }

  if $postgresql_ssl_on {
    $subname = @("EOT"/L)
      ${subname_default}?\
      ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&\
      sslmode=verify-full&sslrootcert=${ssl_ca_cert_path}&\
      sslkey=${ssl_key_pk8_path}&sslcert=${ssl_cert_path}\
      | EOT
  } else {
    $subname = $subname_default
  }

  ini_setting { 'puppetdb_psdatabase_username':
    setting => 'username',
    value   => $database_username,
  }

  if $database_password != undef and $manage_db_password {
    ini_setting { 'puppetdb_psdatabase_password':
      setting   => 'password',
      value     => $database_password,
      show_diff => false,
    }
  }

  ini_setting { 'puppetdb_pgs':
    setting => 'syntax_pgs',
    value   => true,
  }

  ini_setting { 'puppetdb_subname':
    setting => 'subname',
    value   => $subname,
  }

  ini_setting { 'puppetdb_gc_interval':
    setting => 'gc-interval',
    value   => $gc_interval,
  }

  ini_setting { 'puppetdb_node_purge_gc_batch_limit':
    setting => 'node-purge-gc-batch-limit',
    value   => $node_purge_gc_batch_limit,
  }

  ini_setting { 'puppetdb_node_ttl':
    setting => 'node-ttl',
    value   => $node_ttl,
  }

  ini_setting { 'puppetdb_node_purge_ttl':
    setting => 'node-purge-ttl',
    value   => $node_purge_ttl,
  }

  ini_setting { 'puppetdb_report_ttl':
    setting => 'report-ttl',
    value   => $report_ttl,
  }

  ini_setting { 'puppetdb_conn_max_age':
    setting => 'conn-max-age',
    value   => $conn_max_age,
  }

  ini_setting { 'puppetdb_conn_lifetime':
    setting => 'conn-lifetime',
    value   => $conn_lifetime,
  }

  ini_setting { 'puppetdb_migrate':
    setting => 'migrate',
    value   => $migrate,
  }

  if $openvoxdb::params::database_max_pool_size_setting_name != undef {
    if $database_max_pool_size == 'absent' {
      ini_setting { 'puppetdb_database_max_pool_size':
        ensure  => absent,
        setting => $openvoxdb::params::database_max_pool_size_setting_name,
      }
    } elsif $database_max_pool_size != undef {
      ini_setting { 'puppetdb_database_max_pool_size':
        setting => $openvoxdb::params::database_max_pool_size_setting_name,
        value   => $database_max_pool_size,
      }
    }
  }

  if ($facts_blacklist) and length($facts_blacklist) != 0 {
    $joined_facts_blacklist = join($facts_blacklist, ', ')
    ini_setting { 'puppetdb_facts_blacklist':
      setting => 'facts-blacklist',
      value   => $joined_facts_blacklist,
    }
  } else {
    ini_setting { 'puppetdb_facts_blacklist':
      ensure  => absent,
      setting => 'facts-blacklist',
    }
  }
}
