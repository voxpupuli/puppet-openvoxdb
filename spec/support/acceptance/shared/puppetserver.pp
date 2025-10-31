# some provision environments (docker) may not setup or isolate domains
# this ensures the instance FQDN is always resolved locally
host { 'primary':
  name         => $facts['networking']['fqdn'],
  ip           => $facts['networking']['ip'],
  host_aliases => [
    $facts['networking']['hostname'],
  ],
}

if $facts['os']['family'] == 'RedHat' {
  # TODO: backport to litmusimage, required for serverspec port tests
  package { 'iproute': ensure => installed }

  # TODO: rework this hack, maybe not needed for newer version of postgresl module?
  if versioncmp($facts['os']['release']['major'], '8') >= 0 {
    package { 'disable-builtin-dnf-postgresql-module':
      ensure   => 'disabled',
      name     => 'postgresql',
      provider => 'dnfmodule',
    }

    Yumrepo <| tag == 'postgresql::repo' |>
    -> Package['disable-dnf-postgresql-module']
    -> Package <| tag == 'postgresql' |>
  }
}

$sysconfdir = $facts['os']['family'] ? {
  'Debian' => '/etc/default',
  default  => '/etc/sysconfig',
}

case fact('os.family') {
  'Archlinux': {
    $puppetserver_package = 'puppetserver'
  }
  'Debian', 'RedHat', 'Suse': {
    $puppetserver_package = 'openvox-server'
  }
  default: {
    fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
  }
}

package { $puppetserver_package:
  ensure => installed,
}
-> exec { '/opt/puppetlabs/bin/puppetserver ca setup':
  creates => '/etc/puppetlabs/puppetserver/ca/ca_crt.pem',
}
# drop memory requirements to fit on a low memory containers
-> augeas { 'puppetserver-environment':
  context => "/files${sysconfdir}/puppetserver",
  changes => [
    'set JAVA_ARGS \'"-Xms512m -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"\'',
  ],
}
-> service { 'puppetserver':
  ensure => running,
  enable => true,
}
