class existdb::reverseproxy (
  $server_name,
  $server_cert_name = $server_name,
  $exist_home = '/usr/local/existdb',
) {
  include nginx
  nginx::resource::server { $server_name:
    proxy            => 'http://127.0.0.1:8080',
    ssl              => true,
    ssl_redirect     => true,
    ssl_cert         => "/etc/pki/tls/certs/${server_cert_name}.crt",
    ssl_key          => "/etc/pki/tls/private/${server_cert_name}.key",
    proxy_set_header => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Host $host',
      'X-Forwarded-Proto $scheme',
      'Proxy ""',
    ],
    require          => Class['existdb'],
  }

  augeas { 'eXist jetty-http.xml':
    lens    => 'Xml.lns',
    incl    => "${exist_home}/tools/jetty/etc/jetty-http.xml",
    context => "/files${exist_home}/tools/jetty/etc/jetty-http.xml/",
    changes => [
      'ins Configure/New before Configure/Call[#attribute/name = "addConnector"]',
      'set Configure/New[first()]/#attribute/id httpConfig',
      'set Configure/New[#attribute/id = "httpConfig"]/#attribute/class org.eclipse.jetty.server.HttpConfiguration',
      'set Configure/New[#attribute/id = "httpConfig"]/Call/#attribute/name addCustomizer',
      'set Configure/New[#attribute/id = "httpConfig"]/Call/Arg/New/#attribute/class org.eclipse.jetty.server.ForwardedRequestCustomizer',
    ],
    onlyif  => 'match Configure/New[#attribute/id = "httpConfig"] size == 0',
    require => Vcsrepo[$exist_home],
    notify  => Service['eXist-db'],
  }
}
