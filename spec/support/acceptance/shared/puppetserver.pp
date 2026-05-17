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

  # EL 8 and 9 ship a built-in DNF module for postgresql that must be disabled
  # before installing from the upstream PGDG repo. EL 10 dropped the module stream.
  if versioncmp($facts['os']['release']['major'], '8') >= 0 {
    if versioncmp($facts['os']['release']['major'], '10') < 0 {
      # EL 8 and 9
      package { 'disable-builtin-dnf-postgresql-module':
        ensure   => 'disabled',
        name     => 'postgresql',
        provider => 'dnfmodule',
      }

      Yumrepo <| tag == 'postgresql::repo' |>
      -> Package['disable-builtin-dnf-postgresql-module']
      -> Package <| tag == 'postgresql' |>
    } else {
      # EL 10
      Yumrepo <| tag == 'postgresql::repo' |>
      -> Package <| tag == 'postgresql' |>
    }
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
  'Debian', 'RedHat', 'Suse', 'Gentoo': {
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
