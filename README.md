# eXistdb Puppet module

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with existdb](#setup)
    * [Beginning with existdb](#beginning-with-existdb)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module installs the eXist database software and starts it as a service.

## Setup

### Beginning with existdb

To use this module, add these declarations to your Puppetfile:

```
mod 'puppetlabs-java', '2.1.0'
mod 'jonhallettuob-existdb', '0.2.19'
```

To install eXistdb and start it as a service with default parameters:

```
class { 'java':
  package => 'java-1.8.0-openjdk-devel',
}
class { 'existdb': }
```

Or equivalently in Hiera:

```
---
classes:
  - java
  - existdb

java::package: 'java-1.8.0-openjdk-devel'
```

To configure a reverse proxy to make eXistdb appear on port 443, add `mod 'puppet-nginx', '0.9.0'` to your Puppetfile and then in Hiera:

```
classes:
  - existdb::reverseproxy

existdb::reverseproxy::servers:
  'server.example.com':
    server_cert_name: 'server.example.com'
    uri_path: '/exist/apps/example.com'
```

## Usage

Set up eXistdb and its data in specific directories:

```
class existdb {
  exist_home => '/usr/local/exist',
  exist_data => '/var/lib/exist',
}
```

## Reference

```
class existdb (
  $exist_home                  = '/usr/local/existdb',
  $exist_data                  = '/var/lib/existdb',
  $exist_cache_size            = '128M',
  $exist_collection_cache_size = '24M',
  $exist_revision              = 'eXist-4.5.0',
  $java_home                   = '/usr/lib/jvm/jre',
  $exist_user                  = 'existdb',
  $exist_group                 = 'existdb',
) {
 ...
}

class existdb::reverseproxy (
  $servers,
  $exist_home = '/usr/local/existdb',
) {
 ...
}

define existdb::reverseproxy::server {
  $server_name,
  $server_cert_name = $server_name,
  $ssl_cert = "/etc/pki/tls/certs/${server_cert_name}.crt",
  $ssl_key = "/etc/pki/tls/private/${server_cert_name}.key",
  $uri_path = '',
  $proxy_redirect = 'default',
  $location_cfg_append = undef,
  $raw_append = undef,
) {
 ...
}
```

## Limitations

The module was developed on CentOS 7 using Puppet 4 and hasn't been tested on any other systems.
