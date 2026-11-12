# @summary manage the puppetdb.conf file on the puppet primary
#
# @param server
#   The PuppetDB server, or a list of them. With several servers, the terminus
#   uses the first one and fails over to the next ones in order.
#
# @api private
class openvoxdb::master::puppetdb_conf (
  Variant[Stdlib::Host, Array[Stdlib::Host, 1]] $server = 'localhost',
  $port                                                 = '8081',
  $soft_write_failure                                   = $openvoxdb::disable_ssl ? {
    true => true,
    default => false,
  },
  $puppet_confdir                                       = $openvoxdb::params::puppet_confdir,
  $legacy_terminus                                      = $openvoxdb::params::terminus_package ? {
    /(puppetdb-terminus)/ => true,
    default               => false,
  },
) inherits openvoxdb::params {
  Ini_setting {
    ensure  => present,
    section => 'main',
    path    => "${puppet_confdir}/puppetdb.conf",
  }

  $servers = [$server].flatten

  if $legacy_terminus {
    if $servers.length > 1 {
      fail('The legacy PuppetDB terminus only supports a single PuppetDB server')
    }

    ini_setting { 'puppetdbserver':
      setting => 'server',
      value   => $servers[0],
    }
    ini_setting { 'puppetdbport':
      setting => 'port',
      value   => $port,
    }
  } else {
    ini_setting { 'puppetdbserver_urls':
      setting => 'server_urls',
      value   => $servers.map |$host| { "https://${host}:${port}/" }.join(','),
    }
  }

  ini_setting { 'soft_write_failure':
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
  }
}
