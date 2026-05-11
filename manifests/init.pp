# @summary manage PuppetDB
#
# @param listen_address
#   The address that the web server should bind to for HTTP requests. Defaults to
#   `localhost`. Set to `0.0.0.0` to listen on all addresses.
#
# @param listen_port
#   The port on which the puppetdb web server should accept HTTP requests. Defaults
#   to `8080`.
#
# @param disable_cleartext
#   If `true`, the puppetdb web server will only serve HTTPS and not HTTP requests (defaults to false).
#
# @param open_listen_port
#   If `true`, open the `http_listen_port` on the firewall. Defaults to `false`.
#
# @param ssl_listen_address
#   The address that the web server should bind to for HTTPS requests. Defaults to
#   `0.0.0.0` to listen on all addresses.
#
# @param ssl_listen_port
#   The port on which the puppetdb web server should accept HTTPS requests. Defaults
#   to `8081`.
#
# @param disable_ssl
#   If `true`, the puppetdb web server will only serve HTTP and not HTTPS requests.
#   Defaults to `false`.
#
# @param open_ssl_listen_port
#   If true, open the `ssl_listen_port` on the firewall. Defaults to `false`.
#
# @param ssl_protocols
#   Specify the supported SSL protocols for PuppetDB (e.g. TLSv1, TLSv1.1, TLSv1.2.)
#
# @param postgresql_ssl_on
#   If `true`, it configures SSL connections between PuppetDB and the PostgreSQL database.
#   Defaults to `false`.
#
# @param postgresql_ssl_folder
#   Path to the Postgresql SSL folder.
#
# @param postgresql_ssl_cert_path
#   Path to the Postgresql SSL certificate.
#
# @param postgresql_ssl_key_path
#   Path to the Postgresql SSL key.
#
# @param postgresql_ssl_ca_cert_path
#   Path to the Postgresql SSL CA.
#
# @param cipher_suites
#   Configure jetty's supported `cipher-suites` (e.g. `SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384`).
#   Defaults to `undef`.
#
# @param migrate
#   If `true`, puppetdb will automatically migrate to the latest database format at startup. If `false`, if the database format supplied by this version of PuppetDB doesn't match the version expected (whether newer or older), PuppetDB will exit with an error status. Defaults to `true`.
#
# @param manage_dbserver
#   If true, the PostgreSQL server will be managed by this module. Defaults to `true`.
#
# @param manage_database
#   If true, the PostgreSQL database will be managed by this module. Defaults to `true`.
#
# @param manage_package_repo
#   If `true`, the official postgresql.org repo will be added and postgres won't
#   be installed from the regular repository. Defaults to `true`.
#
# @param postgres_version
#   If the postgresql.org repo is installed, you can install several versions of
#   postgres. Defaults to `11` with PuppetDB version 7.0.0 or newer, and `9.6` in older versions.
#
# @param database_host
#   Hostname to use for the database connection. For single case installations this
#   should be left as the default. Defaults to `localhost`.
#
# @param database_port
#   The port that the database server listens on. Defaults to `5432`.
#
# @param database_username
#   The name of the database user to connect as. Defaults to `puppetdb`.
#
# @param database_password
#   The password for the database user. Defaults to `puppetdb`.
#
# @param manage_db_password
#   Whether or not the database password in database.ini will be managed by this module.
#   Set this to `false` if you want to set the password some other way.
#   Defaults to `true`
#
# @param database_name
#   The name of the database instance to connect to. Defaults to `puppetdb`.
#
# @param jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?'
#   character. For example, to use SSL for the PostgreSQL connection, set this
#   parameter's value to `?ssl=true`.
#
# @param database_listen_address
#   A comma-separated list of hostnames or IP addresses on which the postgres
#   server should listen for incoming connections. This defaults to `localhost`.
#   This parameter maps directly to PostgreSQL's `listen_addresses`
#   config option. Use a `*` to allow connections on any accessible address.
#
# @param database_validate
#   If true, the module will attempt to connect to the database using the specified
#   settings and fail if it is not able to do so. Defaults to `true`.
#
# @param node_ttl
#   The length of time a node can go without receiving any new data before it's
#   automatically deactivated. (defaults to '7d', which is a 7-day period. Set to
#   '0d' to disable auto-deactivation).  This option is supported in PuppetDB >=
#   1.1.0.
#
# @param node_purge_ttl
#   The length of time a node can be deactivated before it's deleted from the
#   database. (defaults to '14d', which is a 14-day period. Set to '0d' to disable
#   purging). This option is supported in PuppetDB >= 1.2.0.
#
# @param report_ttl
#   The length of time reports should be stored before being deleted. (defaults to
#   `14d`, which is a 14-day period). This option is supported in PuppetDB >= 1.1.0.
#
# @param facts_blacklist
#   A list of fact names to be ignored whenever submitted.
#
# @param gc_interval
#   This controls how often (in minutes) to compact the database. The compaction
#   process reclaims space and deletes unnecessary rows. If not supplied, the
#   default is every 60 minutes. This option is supported in PuppetDB >= 0.9.
#
# @param node_purge_gc_batch_limit
#   Nodes will be purged in batches of this size, one batch per gc-interval.
#
# @param conn_max_age
#   The maximum time (in minutes) for a pooled connection to remain unused before
#   it is closed off.
#
#   If not supplied, we default to `60` minutes. This option is supported in PuppetDB >= 1.1.
#
# @param conn_lifetime
#   The maximum time (in minutes) a pooled connection should remain open. Any
#   connections older than this setting will be closed off. Connections currently in
#   use will not be affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This
#   option is supported in PuppetDB >= 1.4.
#
# @param puppetdb_package
#   The PuppetDB package name in the package manager. Defaults to `present`.
#
# @param puppetdb_service
#   The name of the PuppetDB service. Defaults to `puppetdb`.
#
# @param puppetdb_service_status
#   Sets whether the service should be `running ` or `stopped`. When set to `stopped` the
#   service doesn't start on boot either. Valid values are `true`, `running`,
#   `false`, and `stopped`.
#
# @param puppetdb_user
#   Puppetdb service user
#
# @param puppetdb_group
#   Puppetdb service group
#
# @param puppetdb_server
#   Puppetdb server hostname or IP address.
#
# @param confdir
#   The PuppetDB configuration directory. Defaults to `/etc/puppetdb/conf.d`.
#
# @param vardir
#   The parent directory for the MQ's data directory.
#
# @param java_args
#   Java VM options used for overriding default Java VM options specified in
#   PuppetDB package. Defaults to `{}`. See
#   [PuppetDB Configuration](https://puppet.com/docs/puppetdb/latest/configure.html)
#   to get more details about the current defaults.
#
#   For example, to set `-Xmx512m -Xms256m` options use:
#
#       {
#           '-Xmx' => '512m',
#           '-Xms' => '256m',
#       }
#
# @param merge_default_java_args
#   Sets whether the provided java args should be merged with the defaults, or
#   should override the defaults. This setting is necessary if any of the defaults
#   are to be removed. Defaults to true. If `false`, the `java_args` in the PuppetDB
#   init config file will reflect only what is passed via the `java_args` param.
#
# @param max_threads
#   Jetty option to explicitly set `max-threads`. Defaults to `undef`, so the
#   PuppetDB-Jetty default is used.
#
# @param puppetdb_version
#   Version of the PuppetDB package to install. Defaults to `present`
#
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to `undef`, and
#   `manage_database` is set to `true`, it will use the value of the `database_host`
#   parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_database_port
#   The port that the read database server listens on. If `read_database_host`
#   is set to `undef`, and `manage_database` is set to `true`, it will use the value of
#   the `database_port` parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_database_username
#   The name of the read database user to connect as. Defaults to `puppetdb-read`. This
#   option is supported in PuppetDB >= 1.6.
#
# @param read_database_password
#   The password for the read database user. Defaults to `puppetdb-read`. This option is
#   supported in PuppetDB >= 1.6.
#
# @param manage_read_db_password
#   Whether or not the database password in read-database.ini will be managed by this module.
#   Set this to `false` if you want to set the password some other way.
#   Defaults to `true`
#
# @param read_database_jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?'
#   character. For example, to use SSL for the PostgreSQL connection, set this
#   parameter's value to `?ssl=true`.
#
# @param read_database_validate
#   If true, the module will attempt to connect to the database using the specified
#   settings and fail if it is not able to do so. Defaults to `true`.
#
# @param read_database_name
#   The name of the read database instance to connect to. If `read_database_host`
#   is set to `undef`, and `manage_database` is set to `true`, it will use the value of
#   the `database_name` parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_conn_max_age
#   The maximum time (in minutes) for a pooled read database connection to remain
#   unused before it is closed off.
#
#   If not supplied, we default to 60 minutes. This option is supported in PuppetDB >= 1.6.
#
# @param read_conn_lifetime
#   The maximum time (in minutes) a pooled read database connection should remain
#   open. Any connections older than this setting will be closed off. Connections
#   currently in use will not be affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This
#   option is supported in PuppetDB >= 1.6.
#
# @param ssl_dir
#   Base directory for PuppetDB SSL configuration. Defaults to `/etc/puppetdb/ssl`
#   or `/etc/puppetlabs/puppetdb/ssl` for FOSS and PE respectively.
#
# @param ssl_set_cert_paths
#   A switch to enable or disable the management of SSL certificates in your
#   `jetty.ini` configuration file.
#
# @param ssl_cert_path
#   Path to your SSL certificate for populating `jetty.ini`.
#
# @param ssl_key_pk8_path
#   Path to the SSL pk8 key for populating `jetty.ini`, will be generated from
#   the SSL key as needed automatically.
#
# @param ssl_key_path
#   Path to your SSL key for populating `jetty.ini`.
#
# @param ssl_ca_cert_path
#   Path to your SSL CA for populating `jetty.ini`.
#
# @param ssl_deploy_certs
#   A boolean switch to enable or disable the management of SSL keys in your
#   `ssl_dir`. Default is `false`.
#
# @param ssl_key
#   Contents of your SSL key, as a string.
#
# @param ssl_cert
#   Contents of your SSL certificate, as a string.
#
# @param ssl_ca_cert
#   Contents of your SSL CA certificate, as a string.
#
# @param manage_firewall
#   If `true`, puppet will manage your iptables rules for PuppetDB via the
#   [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) class.
#
# @param command_threads
#   The number of command processing threads to use. Defaults to `undef`, using the
#   PuppetDB built-in default.
#
# @param concurrent_writes
#   The number of threads allowed to write to disk at any one time. Defaults to
#   `undef`, which uses the PuppetDB built-in default.
#
# @param store_usage
#   The amount of disk space (in MB) to allow for persistent message storage.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param temp_usage
#   The amount of disk space (in MB) to allow for temporary message storage.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param disable_update_checking
#   Setting this to true disables checking for updated versions of PuppetDB and sending basic analytics data to Puppet.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param certificate_whitelist_file
#   The name of the certificate whitelist file to set up and configure in PuppetDB. Defaults to `/etc/puppetdb/certificate-whitelist` or `/etc/puppetlabs/puppetdb/certificate-whitelist` for FOSS and PE respectively.
#
# @param certificate_whitelist
#   Array of the X.509 certificate Common Names of clients allowed to connect to PuppetDB. Defaults to empty. Be aware that this permits full access to all Puppet clients to download anything contained in PuppetDB, including the full catalogs of all nodes, which possibly contain sensitive information. Set to `[ $::servername ]` to allow access only from your (single) Puppet master, which is enough for normal operation. Set to a list of Puppet masters if you have multiple.
#
# @param database_max_pool_size
#   When the pool reaches this size, and no idle connections are available, attempts to get a connection will wait for connection-timeout milliseconds before timing out.
#   Note that PuppetDB will use one pool for writes and another for reads, so the total number of connections used will be twice this setting.
#
# @param read_database_max_pool_size
#   When the pool reaches this size, and no idle connections are available, attempts to get a connection will wait for connection-timeout milliseconds before timing out.
#   Note that PuppetDB will use one pool for writes and another for reads, so the total number of connections used will be twice this setting.
#
# @param automatic_dlo_cleanup
#   PuppetDB creates [Dead Letter Office](https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office).
#   Those are reports of failed requests. They spill up the disk. This parameter is
#   a boolean and defaults to false. You can enable automatic cleanup of DLO
#   reports by setting this to true.
#
# @param cleanup_timer_interval
#   The DLO cleanup is a systemd timer if systemd is available, otherwise a
#   cronjob. The variable configures the systemd.timer option [onCalender](https://www.freedesktop.org/software/systemd/man/systemd.timer.html#OnCalendar=).
#   It defaults to `*-*-* ${fqdn_rand(24)}:${fqdn_rand(60)}:00`. This will start
#   the cleanup service on a daily basis. The exact minute and hour is random
#   per node based on the [fqdn_rand](https://puppet.com/docs/puppet/5.5/function.html#fqdnrand)
#   method. On non-systemd systems, the cron runs daily and the `$puppetdb_user` needs
#   to be able to run cron jobs. On systemd systems you need the [camptocamp/systemd](https://forge.puppet.com/camptocamp/systemd)
#   module, which is an optional dependency and not automatically installed!
#
# @param dlo_max_age
#   This is a positive integer. It describes the amount of days you want to keep
#   the DLO reports. The default value is 90 days.
#
# @param java_bin
#   java binary path for PuppetDB. If undef, default will be used.
#
# @param postgresql_password_encryption
#   PostgreSQL password authentication method, either `md5` or `scram-sha-256`
#
class openvoxdb (
  Stdlib::Host $listen_address                                           = $openvoxdb::params::listen_address,
  Stdlib::Port::Unprivileged $listen_port                                = $openvoxdb::params::listen_port,
  Boolean $disable_cleartext                                             = $openvoxdb::params::disable_cleartext,
  Boolean $open_listen_port                                              = $openvoxdb::params::open_listen_port,
  Stdlib::Host $ssl_listen_address                                       = $openvoxdb::params::ssl_listen_address,
  Stdlib::Port::Unprivileged $ssl_listen_port                            = $openvoxdb::params::ssl_listen_port,
  Boolean $disable_ssl                                                   = $openvoxdb::params::disable_ssl,
  Boolean $open_ssl_listen_port                                          = $openvoxdb::params::open_ssl_listen_port,
  Stdlib::Unixpath $ssl_dir                                              = $openvoxdb::params::ssl_dir,
  Boolean $ssl_set_cert_paths                                            = $openvoxdb::params::ssl_set_cert_paths,
  Stdlib::Unixpath $ssl_cert_path                                        = $openvoxdb::params::ssl_cert_path,
  Stdlib::Unixpath $ssl_key_path                                         = $openvoxdb::params::ssl_key_path,
  Stdlib::Unixpath $ssl_key_pk8_path                                     = $openvoxdb::params::ssl_key_pk8_path,
  Stdlib::Unixpath $ssl_ca_cert_path                                     = $openvoxdb::params::ssl_ca_cert_path,
  Boolean $ssl_deploy_certs                                              = $openvoxdb::params::ssl_deploy_certs,
  Optional[Variant[String[1], Sensitive[String[1]]]] $ssl_key            = $openvoxdb::params::ssl_key,
  Optional[Variant[String[1], Sensitive[String[1]]]] $ssl_cert           = $openvoxdb::params::ssl_cert,
  Optional[Variant[String[1], Sensitive[String[1]]]] $ssl_ca_cert        = $openvoxdb::params::ssl_ca_cert,
  Optional[String[1]] $ssl_protocols                                     = $openvoxdb::params::ssl_protocols,
  Boolean $postgresql_ssl_on                                             = $openvoxdb::params::postgresql_ssl_on,
  Stdlib::Unixpath $postgresql_ssl_folder                                = $openvoxdb::params::postgresql_ssl_folder,
  Stdlib::Unixpath $postgresql_ssl_cert_path                             = $openvoxdb::params::postgresql_ssl_cert_path,
  Stdlib::Unixpath $postgresql_ssl_key_path                              = $openvoxdb::params::postgresql_ssl_key_path,
  Stdlib::Unixpath $postgresql_ssl_ca_cert_path                          = $openvoxdb::params::postgresql_ssl_ca_cert_path,
  Optional[String[1]] $cipher_suites                                     = $openvoxdb::params::cipher_suites,
  Boolean $migrate                                                       = $openvoxdb::params::migrate,
  Boolean $manage_dbserver                                               = $openvoxdb::params::manage_dbserver,
  Boolean $manage_database                                               = $openvoxdb::params::manage_database,
  Boolean $manage_package_repo                                           = $openvoxdb::params::manage_pg_repo,
  String[1] $postgres_version                                            = $openvoxdb::params::postgres_version,
  Stdlib::Host $database_host                                            = $openvoxdb::params::database_host,
  Stdlib::Port::Unprivileged $database_port                              = $openvoxdb::params::database_port,
  String[1] $database_username                                           = $openvoxdb::params::database_username,
  Variant[String[1], Sensitive[String[1]]] $database_password            = $openvoxdb::params::database_password,
  String[1] $database_name                                               = $openvoxdb::params::database_name,
  Boolean $manage_db_password                                            = $openvoxdb::params::manage_db_password,
  Optional[String] $jdbc_ssl_properties                                  = $openvoxdb::params::jdbc_ssl_properties,
  Stdlib::Host $database_listen_address                                  = $openvoxdb::params::postgres_listen_addresses,
  Boolean $database_validate                                             = $openvoxdb::params::database_validate,
  String[1] $node_ttl                                                    = $openvoxdb::params::node_ttl,
  String[1] $node_purge_ttl                                              = $openvoxdb::params::node_purge_ttl,
  String[1] $report_ttl                                                  = $openvoxdb::params::report_ttl,
  Optional[Array] $facts_blacklist                                       = $openvoxdb::params::facts_blacklist,
  Integer $gc_interval                                                   = $openvoxdb::params::gc_interval,
  Integer $node_purge_gc_batch_limit                                     = $openvoxdb::params::node_purge_gc_batch_limit,
  Integer $conn_max_age                                                  = $openvoxdb::params::conn_max_age,
  Integer $conn_lifetime                                                 = $openvoxdb::params::conn_lifetime,
  String[1] $puppetdb_package                                            = $openvoxdb::params::puppetdb_package,
  String[1] $puppetdb_service                                            = $openvoxdb::params::puppetdb_service,
  Stdlib::Ensure::Service $puppetdb_service_status                       = $openvoxdb::params::puppetdb_service_status,
  String[1] $puppetdb_user                                               = $openvoxdb::params::puppetdb_user,
  String[1] $puppetdb_group                                              = $openvoxdb::params::puppetdb_group,
  Stdlib::Host $puppetdb_server                                          = $openvoxdb::params::puppetdb_server,
  String[1] $puppetdb_version                                            = $openvoxdb::params::puppetdb_version,
  Optional[Stdlib::Host] $read_database_host                             = $openvoxdb::params::read_database_host,
  Optional[Stdlib::Port::Unprivileged] $read_database_port               = $openvoxdb::params::read_database_port,
  Optional[String] $read_database_username                               = $openvoxdb::params::read_database_username,
  Optional[Variant[String[1], Sensitive[String[1]]]] $read_database_password = $openvoxdb::params::read_database_password,
  String $read_database_name                                             = $openvoxdb::params::read_database_name,
  Boolean $manage_read_db_password                                       = $openvoxdb::params::manage_read_db_password,
  String $read_database_jdbc_ssl_properties                              = $openvoxdb::params::read_database_jdbc_ssl_properties,
  Boolean $read_database_validate                                        = $openvoxdb::params::read_database_validate,
  Integer $read_conn_max_age                                             = $openvoxdb::params::read_conn_max_age,
  Integer  $read_conn_lifetime                                           = $openvoxdb::params::read_conn_lifetime,
  Stdlib::Unixpath $confdir                                              = $openvoxdb::params::confdir,
  Stdlib::Unixpath $vardir                                               = $openvoxdb::params::vardir,
  Boolean $manage_firewall                                               = $openvoxdb::params::manage_firewall,
  Hash $java_args                                                        = $openvoxdb::params::java_args,
  Boolean $merge_default_java_args                                       = $openvoxdb::params::merge_default_java_args,
  Optional[Integer] $max_threads                                         = $openvoxdb::params::max_threads,
  Optional[Integer] $command_threads                                     = $openvoxdb::params::command_threads,
  Optional[Integer] $concurrent_writes                                   = $openvoxdb::params::concurrent_writes,
  Optional[Integer] $store_usage                                         = $openvoxdb::params::store_usage,
  Optional[Integer] $temp_usage                                          = $openvoxdb::params::temp_usage,
  Optional[Boolean] $disable_update_checking                             = $openvoxdb::params::disable_update_checking,
  Stdlib::Unixpath $certificate_whitelist_file                           = $openvoxdb::params::certificate_whitelist_file,
  Array $certificate_whitelist                                           = $openvoxdb::params::certificate_whitelist,
  Optional[String[1]] $database_max_pool_size                            = $openvoxdb::params::database_max_pool_size,
  Optional[String[1]] $read_database_max_pool_size                       = $openvoxdb::params::read_database_max_pool_size,
  Boolean $automatic_dlo_cleanup                                         = $openvoxdb::params::automatic_dlo_cleanup,
  String[1] $cleanup_timer_interval                                      = $openvoxdb::params::cleanup_timer_interval,
  Integer[1] $dlo_max_age                                                = $openvoxdb::params::dlo_max_age,
  Postgresql::Pg_password_encryption $postgresql_password_encryption     = $openvoxdb::params::password_encryption,
  Optional[Stdlib::Absolutepath] $java_bin                               = $openvoxdb::params::java_bin,
) inherits openvoxdb::params {
  class { 'openvoxdb::server':
    listen_address                    => $listen_address,
    listen_port                       => $listen_port,
    disable_cleartext                 => $disable_cleartext,
    open_listen_port                  => $open_listen_port,
    ssl_listen_address                => $ssl_listen_address,
    ssl_listen_port                   => $ssl_listen_port,
    disable_ssl                       => $disable_ssl,
    open_ssl_listen_port              => $open_ssl_listen_port,
    ssl_dir                           => $ssl_dir,
    ssl_set_cert_paths                => $ssl_set_cert_paths,
    ssl_cert_path                     => $ssl_cert_path,
    ssl_key_path                      => $ssl_key_path,
    ssl_key_pk8_path                  => $ssl_key_pk8_path,
    ssl_ca_cert_path                  => $ssl_ca_cert_path,
    ssl_deploy_certs                  => $ssl_deploy_certs,
    ssl_key                           => $ssl_key,
    ssl_cert                          => $ssl_cert,
    ssl_ca_cert                       => $ssl_ca_cert,
    ssl_protocols                     => $ssl_protocols,
    postgresql_ssl_on                 => $postgresql_ssl_on,
    cipher_suites                     => $cipher_suites,
    migrate                           => $migrate,
    database_host                     => $database_host,
    database_port                     => $database_port,
    database_username                 => $database_username,
    database_password                 => $database_password,
    database_name                     => $database_name,
    manage_db_password                => $manage_db_password,
    jdbc_ssl_properties               => $jdbc_ssl_properties,
    database_validate                 => $database_validate,
    node_ttl                          => $node_ttl,
    node_purge_ttl                    => $node_purge_ttl,
    report_ttl                        => $report_ttl,
    facts_blacklist                   => $facts_blacklist,
    gc_interval                       => $gc_interval,
    node_purge_gc_batch_limit         => $node_purge_gc_batch_limit,
    conn_max_age                      => $conn_max_age,
    conn_lifetime                     => $conn_lifetime,
    puppetdb_package                  => $puppetdb_package,
    puppetdb_service                  => $puppetdb_service,
    puppetdb_service_status           => $puppetdb_service_status,
    confdir                           => $confdir,
    vardir                            => $vardir,
    java_args                         => $java_args,
    merge_default_java_args           => $merge_default_java_args,
    max_threads                       => $max_threads,
    read_database_host                => $read_database_host,
    read_database_port                => $read_database_port,
    read_database_username            => $read_database_username,
    read_database_password            => $read_database_password,
    read_database_name                => $read_database_name,
    manage_read_db_password           => $manage_read_db_password,
    read_database_jdbc_ssl_properties => $read_database_jdbc_ssl_properties,
    read_database_validate            => $read_database_validate,
    read_conn_max_age                 => $read_conn_max_age,
    read_conn_lifetime                => $read_conn_lifetime,
    puppetdb_user                     => $puppetdb_user,
    puppetdb_group                    => $puppetdb_group,
    manage_firewall                   => $manage_firewall,
    manage_database                   => $manage_database,
    command_threads                   => $command_threads,
    concurrent_writes                 => $concurrent_writes,
    store_usage                       => $store_usage,
    temp_usage                        => $temp_usage,
    disable_update_checking           => $disable_update_checking,
    certificate_whitelist_file        => $certificate_whitelist_file,
    certificate_whitelist             => $certificate_whitelist,
    database_max_pool_size            => $database_max_pool_size,
    read_database_max_pool_size       => $read_database_max_pool_size,
    automatic_dlo_cleanup             => $automatic_dlo_cleanup,
    cleanup_timer_interval            => $cleanup_timer_interval,
    dlo_max_age                       => $dlo_max_age,
    java_bin                          => $java_bin,
  }

  $database_before = str2bool($database_validate) ? {
    false => Class['openvoxdb::server'],
    default => [
      Class['openvoxdb::server'],
      Class['openvoxdb::server::validate_db'],
    ],
  }

  class { 'openvoxdb::database::postgresql':
    listen_addresses            => $database_listen_address,
    database_name               => $database_name,
    puppetdb_server             => $puppetdb_server,
    database_username           => $database_username,
    database_password           => $database_password,
    database_port               => $database_port,
    manage_server               => $manage_dbserver,
    manage_database             => $manage_database,
    manage_package_repo         => $manage_package_repo,
    postgres_version            => $postgres_version,
    postgresql_ssl_on           => $postgresql_ssl_on,
    postgresql_ssl_key_path     => $postgresql_ssl_key_path,
    postgresql_ssl_cert_path    => $postgresql_ssl_cert_path,
    postgresql_ssl_ca_cert_path => $postgresql_ssl_ca_cert_path,
    read_database_username      => $read_database_username,
    read_database_password      => $read_database_password,
    read_database_host          => $read_database_host,
    password_encryption         => $postgresql_password_encryption,
    before                      => $database_before,
  }
}
