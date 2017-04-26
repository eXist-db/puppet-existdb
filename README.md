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
mod 'puppetlabs-java', '1.7.0'
mod 'jonhallettuob-existdb', '0.1.8'
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
  $exist_revision              = 'eXist-3.1.1',
  $java_home                   = '/usr/lib/jvm/jre',
  $exist_user                  = 'existdb',
  $exist_group                 = 'existdb',
) {
 ...
}
```

## Limitations

The module was developed on CentOS 7 using Puppet 4 and hasn't been tested on any other systems.
