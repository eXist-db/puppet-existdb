# Install eXistdb from its repository version and start as a service
class existdb (
  $exist_home                  = '/usr/local/existdb',
  $exist_data                  = '/var/lib/existdb',
  $exist_cache_size            = '128M',
  $exist_collection_cache_size = '24M',
  $exist_revision              = 'eXist-4.6.1',
  $java_home                   = '/usr/lib/jvm/jre',
  $exist_user                  = 'existdb',
  $exist_group                 = 'existdb',
) {
  $exist_version = regsubst($exist_revision, '^eXist-', '')

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

  archive { '/tmp/exist.tar.bz2':
    ensure           => present,
    source           => @("SOURCE"/L),
      https://bintray.com/existdb/releases/download_file\
      ?file_path=exist-distribution-${exist_version}-unix.tar.bz2
      |-SOURCE
    download_options => '--location',
    extract          => true,
    extract_path     => '/usr/local',
    user             => 'root',
    group            => 'root',
    cleanup          => true,
  }

  file { $exist_home:
    ensure => link,
    target => "/usr/local/exist-distribution-${exist_version}",
  }

  include java

  augeas { 'eXist conf.xml':
    lens    => 'Xml.lns',
    incl    => "${exist_home}/etc/conf.xml",
    context => "/files${exist_home}/etc/conf.xml/",
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
    ]
  }

  service { 'eXist-db':
    ensure  => running,
    require => [
    ],
  }
}
