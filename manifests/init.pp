# Install eXistdb from its repository version and start as a service
class existdb (
  $exist_home                  = '/usr/local/existdb',
  $exist_data                  = '/var/lib/existdb',
  $exist_cache_size            = '128M',
  $exist_collection_cache_size = '24M',
<<<<<<< HEAD
  $exist_revision              = 'eXist-4.4.0',
=======
  $exist_revision              = 'eXist-4.3.1',
>>>>>>> 8a31cb1bac8aa68f8c6fad83603c0713eeedcad4
  $java_home                   = '/usr/lib/jvm/jre',
  $exist_user                  = 'existdb',
  $exist_group                 = 'existdb',
) {
  group { $exist_group:
    ensure => present,
    system => true,
  }

  user { $exist_user:
    ensure  => present,
    system  => true,
    gid     => $exist_group,
    home    => $exist_home,
    shell   => '/bin/bash',
    comment => 'eXist Server',
  }

  file { $exist_data:
    ensure => directory,
    owner  => $exist_user,
    group  => $exist_group,
    mode   => '0700',
  }

  vcsrepo { $exist_home:
    ensure   => present,
    provider => git,
    owner    => $exist_user,
    group    => $exist_group,
    source   => 'https://github.com/eXist-db/exist.git',
    revision => $exist_revision,
  }

  file { "${exist_home}/extensions/local.build.properties":
    ensure  => present,
    source  => 'puppet:///modules/existdb/local.build.properties',
    require => Vcsrepo[$exist_home],
  }

  include java

  exec { 'build eXist':
    cwd         => $exist_home,
    command     => "${exist_home}/build.sh",
    environment => [
      "JAVA_HOME=${java_home}",
    ],
    timeout     => 0,
    user        => $exist_user,
    group       => $exist_group,
    refreshonly => true,
    subscribe   => Vcsrepo[$exist_home],
    require     => [
      File["${exist_home}/extensions/local.build.properties"],
      Class['java'],
    ],
  }

  exec { 'sign eXist jar files':
    cwd         => $exist_home,
    command     => "${exist_home}/build.sh -f build/scripts/jarsigner.xml -propertyfile build.properties",
    environment => [
      "JAVA_HOME=${java_home}",
    ],
    timeout     => 0,
    user        => $exist_user,
    group       => $exist_group,
    refreshonly => true,
    subscribe   => Exec['build eXist'],
  }

  augeas { 'eXist conf.xml':
    lens    => 'Xml.lns',
    incl    => "${exist_home}/conf.xml",
    context => "/files${exist_home}/conf.xml/",
    changes => [
      "set exist/db-connection/#attribute/files ${exist_data}",
      "set exist/db-connection/#attribute/cacheSize ${exist_cache_size}",
      "set exist/db-connection/#attribute/collectionCache ${exist_collection_cache_size}",
      "set exist/db-connection/recovery/#attribute/journal-dir ${exist_data}",
      'set exist/serializer/#attribute/enable-xsl yes',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/contentextraction"]/#attribute/uri http://exist-db.org/xquery/contentextraction',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/contentextraction"]/#attribute/class org.exist.contentextraction.xquery.ContentExtractionModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/counter"]/#attribute/uri http://exist-db.org/xquery/counter',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/counter"]/#attribute/class org.exist.xquery.modules.counter.CounterModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/exi"]/#attribute/uri http://exist-db.org/xquery/exi',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/exi"]/#attribute/class org.exist.xquery.modules.exi.ExiModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/image"]/#attribute/uri http://exist-db.org/xquery/image',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/image"]/#attribute/class org.exist.xquery.modules.image.ImageModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/mail"]/#attribute/uri http://exist-db.org/xquery/mail',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/mail"]/#attribute/class org.exist.xquery.modules.mail.MailModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/scheduler"]/#attribute/uri http://exist-db.org/xquery/scheduler',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/scheduler"]/#attribute/class org.exist.xquery.modules.scheduler.SchedulerModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/sql"]/#attribute/uri http://exist-db.org/xquery/sql',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/sql"]/#attribute/class org.exist.xquery.modules.sql.SQLModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xmldiff"]/#attribute/uri http://exist-db.org/xquery/xmldiff',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xmldiff"]/#attribute/class org.exist.xquery.modules.xmldiff.XmlDiffModule',

      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xslfo"]/#attribute/uri http://exist-db.org/xquery/xslfo',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xslfo"]/#attribute/class org.exist.xquery.modules.xslfo.XSLFOModule',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xslfo"]/parameter/#attribute/name processorAdapter',
      'set exist/xquery/builtin-modules/module[#attribute/uri = "http://exist-db.org/xquery/xslfo"]/parameter/#attribute/value org.exist.xquery.modules.xslfo.ApacheFopProcessorAdapter',
    ],
    require => [
      Exec['sign eXist jar files'],
      File[$exist_data],
    ]
  }

  exec { 'install eXist':
    cwd         => $exist_home,
    command     => "/bin/yes | ${exist_home}/tools/yajsw/bin/installDaemon.sh",
    environment => [
      "JAVA_HOME=${java_home}",
      "EXIST_HOME=${exist_home}",
      "RUN_AS_USER=${exist_user}",
    ],
    timeout     => 0,
    user        => 'root',
    refreshonly => true,
    subscribe   => Exec['sign eXist jar files'],
  }

  service { 'eXist-db':
    ensure    => running,
    subscribe => [
      Exec['install eXist'],
    ],
    require   => [
      Exec['build eXist'],
      Augeas['eXist conf.xml'],
    ],
  }
}
