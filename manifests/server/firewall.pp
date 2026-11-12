# @summary manage puppetdb firewall rules
#
# @api private
class openvoxdb::server::firewall (
  Stdlib::Port::Unprivileged $http_port = $openvoxdb::params::listen_port,
  Boolean $open_http_port               = $openvoxdb::params::open_listen_port,
  Stdlib::Port::Unprivileged $ssl_port  = $openvoxdb::params::ssl_listen_port,
  Boolean $open_ssl_port                = $openvoxdb::params::open_ssl_listen_port,
) inherits openvoxdb::params {
  include firewall

  if ($open_http_port) {
    firewall { "${http_port} accept - puppetdb":
      dport => $http_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }

  if ($open_ssl_port) {
    firewall { "${ssl_port} accept - puppetdb":
      dport => $ssl_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }
}
