# openvoxdb

#### Table of Contents

1. [Overview - What is the OpenVoxDB module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with OpenVoxDB module](#setup)
4. [Migrating - PuppetDB to OpenVoxDB](#migrating-puppetdb-to-openvoxdb)
5. [Usage - The classes and parameters available for configuration](#usage)
6. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
7. [Limitations - OS compatibility, etc.](#limitations)
8. [Development - Guide for contributing to the module](#development)

## Overview

By guiding OpenVoxDB (community fork of PuppetDB) setup and configuration with a
Puppet master, the OpenVoxDB module provides fast, streamlined access to data
on puppetized infrastructure.

## Module Description

The OpenVoxDB module provides a quick way to get started using OpenVoxDB, an open
source inventory resource service that manages storage and retrieval of
platform-generated data. The module will install PostgreSQL and OpenVoxDB if you
don't have them, as well as set up the connection to Puppet master. The module
will also provide a dashboard you can use to view the current state of your
system.

For more information about PuppetDB
[please see the official PuppetDB documentation.](https://puppet.com/docs/puppetdb/latest/)


## Setup


**What puppet-openvoxdb affects:**

* package/service/configuration files for OpenVoxDB
* package/service/configuration files for PostgreSQL (optional, but set as default)
* Puppet master's runtime (via plugins)
* Puppet master's configuration
  * **note**: Using the `openvoxdb::master::config` class will cause your
    routes.yaml file to be overwritten entirely (see **Usage** below for options
    and more information )
* system firewall (optional)
* listened-to ports

**Introductory Questions**

To begin using OpenVoxDB, you’ll have to make a few decisions:

* Should I run the database on the same node that I run OpenVoxDB on?
* Should I run OpenVoxDB on the same node that I run my master on?

The answers to those questions will be largely dependent on your answers to
questions about your Puppet environment:

* How many nodes are you managing?
* What kind of hardware are you running on?
* Is your current load approaching the limits of your hardware?

Depending on your answers to all of the questions above, you will likely fall
under one of these set-up options:

1. [Single Node (Testing and Development)](#single-node-setup)
2. [Multiple Node (Recommended)](#multiple-node-setup)

### Single Node Setup

This approach assumes you will use our default database (PostgreSQL) and run
everything (PostgreSQL, OpenVoxDB, Puppet master) all on the same node. This
setup will be great for a testing or experimental environment. In this case,
your manifest will look like:

```puppet
node <hostname> {
  # Configure OpenVoxDB and its underlying database
  class { 'openvoxdb': }

  # Configure the Puppet master to use OpenVoxDB
  class { 'openvoxdb::master::config': }
}
```

You can provide some parameters for these classes if you’d like more control,
but that is literally all that it will take to get you up and running with the
default configuration.

### Multiple Node Setup

This approach is for those who prefer not to install OpenVoxDB on the same node
as the Puppet master. Your environment will be easier to scale if you are able
to dedicate hardware to the individual system components. You may even choose to
run the OpenVoxDB server on a different node from the PostgreSQL database that it
uses to store its data. So let’s have a look at what a manifest for that
scenario might look like:

**This is an example of a very basic 3-node setup for OpenVoxDB.**

    $puppetdb_host = 'puppetdb.example.com'
    $postgres_host = 'postgres.example.com'
    node 'master.example.com' {
      # Here we configure the Puppet master to use OpenVoxDB,
      # telling it the hostname of the OpenVoxDB node
      class { 'openvoxdb::master::config':
        puppetdb_server => $puppetdb_host,
      }
    }
    node 'postgres.example.com' {
      # Here we install and configure PostgreSQL and the OpenVoxDB
      # database instance, and tell PostgreSQL that it should
      # listen for connections to the `$postgres_host`
      class { 'openvoxdb::database::postgresql':
        listen_addresses => $postgres_host,
      }
    }
    node 'puppetdb.example.com' {
      # Here we install and configure OpenVoxDB, and tell it where to
      # find the PostgreSQL database.
      class { 'openvoxdb::server':
        database_host => $postgres_host,
      }
    }

This should be all it takes to get a 3-node, distributed installation of
OpenVoxDB up and running. Note that, if you prefer, you could easily move two of
these classes to a single node and end up with a 2-node setup instead.

#### Several OpenVoxDB servers

The Puppet master can use several OpenVoxDB servers sharing the same database:
it sends everything to the first one and fails over to the next ones, in order,
when it is unreachable.

    class { 'openvoxdb::master::config':
      puppetdb_server => ['puppetdb1.example.com', 'puppetdb2.example.com'],
    }

The connection check of `strict_validation` succeeds as soon as one of them is
reachable. Only one of the OpenVoxDB servers should migrate the database schema
and run the garbage collection: set `migrate => false` and `gc_interval => 0`
on `openvoxdb::server` on the others.

### Enable SSL connections

To use SSL connections for the single node setup, use the following manifest:

    node <hostname> {
      # Here we configure openvoxdb and PostgreSQL to use ssl connections
      class { 'openvoxdb':
        postgresql_ssl_on => true,
        database_host => '<hostname>',
        database_listen_address => '0.0.0.0'
      }

      # Configure the Puppet master to use openvoxdb
      class { 'openvoxdb::master::config': }

To use SSL connections for the multiple nodes setup, use the following manifest:

    $puppetdb_host = 'puppetdb.example.com'
    $postgres_host = 'postgres.example.com'

    node 'master.example.com' {
      # Here we configure the Puppet master to use OpenVoxDB,
      # telling it the hostname of the OpenVoxDB node.
      class { 'openvoxdb::master::config':
        puppetdb_server => $puppetdb_host,
      }
    }

    node 'postgres.example.com' {
      # Here we install and configure PostgreSQL and the OpenVoxDB
      # database instance, and tell PostgreSQL that it should
      # listen for connections to the `$postgres_host`.
      # We also enable SSL connections.
      class { 'puppetdb::database::postgresql':
        listen_addresses => $postgres_host,
        postgresql_ssl_on => true,
        puppetdb_server => $puppetdb_host
      }
    }

    node 'puppetdb.example.com' {
      # Here we install and configure OpenVoxDB, and tell it where to
      # find the PostgreSQL database. We also enable SSL connections.
      class { 'openvoxdb::server':
        database_host => $postgres_host,
        postgresql_ssl_on => true
      }
    }

### Beginning with OpenVoxDB

Whether you choose a single node development setup or a multi-node setup, a
basic setup of OpenVoxDB will cause: PostgreSQL to install on the node if it’s
not already there; OpenVoxDB postgres database instance and user account to be
created; the postgres connection to be validated and, if successful, OpenVoxDB to
be installed and configured; OpenVoxDB connection to be validated and, if
successful, the Puppet master config files to be modified to use OpenVoxDB; and
the Puppet master to be restarted so that it will pick up the config changes.

If your logging level is set to INFO or finer, you should start seeing
OpenVoxDB-related log messages appear in both your Puppet master log and your
OpenVoxDB log as subsequent agent runs occur.

### Cross-node Dependencies

It is worth noting that there are some cross-node dependencies, which means that
the first time you add the module's configurations to your manifests, you may
see a few failed puppet runs on the affected nodes.

OpenVoxDB handles cross-node dependencies by taking a sort of "eventual
consistency" approach. There’s nothing that the module can do to control the
order in which your nodes check in, but the module can check to verify that the
services it depends on are up and running before it makes configuration
changes--so that’s what it does.

When your Puppet master node checks in, it will validate the connectivity to the
OpenVoxDB server before it applies its changes to the Puppet master config files.
If it can’t connect to OpenVoxDB, then the puppet run will fail and the previous
config files will be left intact. This prevents your master from getting into a
broken state where all incoming puppet runs fail because the master is
configured to use a OpenVoxDB server that doesn’t exist yet. The same strategy is
used to handle the dependency between the OpenVoxDB server and the postgres
server.

Hence the failed puppet runs. These failures should be limited to 1 failed run
on the OpenVoxDB node, and up to 2 failed runs on the Puppet master node. After
that, all of the dependencies should be satisfied and your puppet runs should
start to succeed again.

You can also manually trigger puppet runs on the nodes in the correct order
(Postgres, OpenVoxDB, Puppet master), which will avoid any failed runs.

## Migrating PuppetDB to OpenVoxDB

Actually the `puppet-openvoxdb` module keeps the same parameter names of `puppetlabs-puppetdb`.
If you are already using PuppetDB 8.x, it _should_ be enough to add OpenVox repositories, rename the classes in your manifest and type check the parameters:

```puppet
class { 'puppetdb':
  # All your parameters here
}

# Renamed to
class { 'openvoxdb':
  # Same parameters as before, with the correct data type
}
```

Anyway you are advised to **backup before migrating**, test the migration in a
separate environment and run it manually to be sure.

**Migration from `puppetlabs/puppetdb` to `puppet/openvoxdb` also introduces type checking of parameters**.

**Upgrade from PuppetDB < 8.x is currently unsupported**.

## Usage

OpenVoxDB supports a large number of configuration options for both configuring
the OpenVoxDB service and connecting that service to the Puppet master.

### openvoxdb

The `openvoxdb` class is intended as a high-level abstraction (sort of an
'all-in-one' class) to help simplify the process of getting your openvoxdb server
up and running. It wraps the slightly-lower-level classes `openvoxdb::server` and
`openvoxdb::database::*`, and it'll get you up and running with everything you
need (including database setup and management) on the server side. For maximum
configurability, you may choose not to use this class. You may prefer to use the
`openvoxdb::server` class directly, or manage your openvoxdb setup on your own.

You must declare the class to use it:

    class { 'openvoxdb': }

### openvoxdb::server

The `openvoxdb::server` class manages the OpenVoxDB server independently of the
underlying database that it depends on. It will manage the OpenVoxDB package,
service, config files, etc., but will still allow you to manage the database
(e.g. PostgreSQL) however you see fit.

    class { 'openvoxdb::server':
      database_host => 'pg1.mydomain.com',
    }

### openvoxdb::master::config

The `openvoxdb::master::config` class directs your Puppet master to use OpenVoxDB,
which means that this class should be used on your Puppet master node. It’ll
verify that it can successfully communicate with your OpenVoxDB server, and then
configure your master to use OpenVoxDB.

Using this class allows the module to manipulate the puppet configuration files
puppet.conf and routes.yaml. The puppet.conf changes are supplemental and should
not affect any of your existing settings, but the routes.yaml file will be
overwritten entirely. If you have an existing routes.yaml file, you will want to
take care to use the `manage_routes` parameter of this class to prevent the module
from managing that file, and you’ll need to manage it yourself.

    class { 'openvoxdb::master::config':
      puppetdb_server => 'my.host.name',
      puppetdb_port   => 8081,
    }

### openvoxdb::database::postgresql

The `openvoxdb::database::postgresql` class manages a PostgreSQL server for use
by OpenVoxDB. It can manage the PostgreSQL packages and service, as well as
creating and managing the OpenVoxDB database and database user accounts.

    class { 'openvoxdb::database::postgresql':
      listen_addresses => 'my.postgres.host.name',
    }

## Implementation

### Resource overview

In addition to the classes and variables mentioned above, OpenVoxDB includes:

**openvoxdb::master::routes**

Configures the Puppet master to use OpenVoxDB as the facts terminus. *WARNING*:
the current implementation simply overwrites your routes.yaml file; if you have
an existing routes.yaml file that you are using for other purposes, you should
*not* use this.

    class { 'openvoxdb::master::routes':
      puppet_confdir => '/etc/puppet'
    }

The optional parameter routes can be used to specify a custom route
configuration. For example to configure routes for masterless puppet.

    class { 'openvoxdb::master::routes':
      routes => {
        'apply' => {
          'facts' => {
            'terminus' => 'facter',
            'cache'    => 'puppetdb_apply',
          }
        }
      }
    }

**openvoxdb::master::storeconfigs**

Configures the Puppet master to enable storeconfigs and to use OpenVoxDB as the
storeconfigs backend.

    class { 'openvoxdb::master::storeconfigs':
      puppet_conf => '/etc/puppet/puppet.conf'
    }

**openvoxdb::server::validate_db**

Validates that a successful database connection can be established between the
node on which this resource is run and the specified OpenVoxDB database instance
(host/port/user/password/database name).

    openvoxdb::server::validate_db { 'validate my openvoxdb database connection':
      database_host     => 'my.postgres.host',
      database_username => 'mydbuser',
      database_password => 'mydbpassword',
      database_name     => 'mydbname',
    }

### Custom Types

**puppetdb_conn_validator**

Verifies that a connection can be successfully established between a node and
the OpenVoxDB server. Its primary use is as a precondition to prevent
configuration changes from being applied if the OpenVoxDB server cannot be
reached, but it could potentially be used for other purposes such as monitoring.

## Limitations

Supported OSes and dependencies are given into [metadata.json file](https://github.com/voxpupuli/puppet-openvoxdb/blob/main/metadata.json).

Currently, puppet-openvoxdb is compatible with OpenVoxDB 8.x

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli
welcomes new contributions to this module, especially those that include
documentation and rspec tests. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](https://github.com/voxpupuli/.github/blob/master/CONTRIBUTING.md) for more details.

### Authors

* Forked from [puppetlabs-puppetdb](https://github.com/puppetlabs/puppetlabs-puppetdb), git history is preserved
* Subsequent development by [Vox Pupuli](https://voxpupuli.org/)