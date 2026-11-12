# @summary manages the routes configuration file on the master
#
# @api private
class openvoxdb::master::routes (
  Stdlib::Absolutepath $puppet_confdir = $openvoxdb::params::puppet_confdir,
  Boolean $masterless                  = $openvoxdb::params::masterless,
  Optional[Hash] $routes               = undef,
) inherits openvoxdb::params {
  if $masterless {
    $routes_real = {
      'apply' => {
        'catalog' => {
          'terminus' => 'compiler',
          'cache'    => 'puppetdb',
        },
        'facts'   => {
          'terminus' => 'facter',
          'cache'    => 'puppetdb_apply',
        },
      },
    }
  } elsif $routes {
    $routes_real = $routes
  } else {
    $default_fact_cache = 'json'
    $routes_real = {
      'master' => {
        'facts' => {
          'terminus' => 'puppetdb',
          'cache'    => $default_fact_cache,
        },
      },
    }
  }

  # TODO: this will overwrite any existing routes.yaml;
  #  to handle this properly we should just be ensuring
  #  that the proper settings exist, but to do that we'd need
  #  to parse the yaml file and rewrite it, dealing with indentation issues etc
  #  I don't think there is currently a puppet module or an augeas lens for
  #  this.
  file { "${puppet_confdir}/routes.yaml":
    ensure  => file,
    content => template('openvoxdb/routes.yaml.erb'),
    mode    => '0644',
  }
}
