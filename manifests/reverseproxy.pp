class existdb::reverseproxy (
  $servers,
  $exist_home = '/usr/local/existdb',
) {
  create_resources(existdb::reverseproxy::server, $servers)

  augeas { 'eXist jetty-http.xml':
    lens    => 'Xml.lns',
    incl    => "${exist_home}/tools/jetty/etc/jetty-http.xml",
    context => "/files${exist_home}/tools/jetty/etc/jetty-http.xml/",
    changes => [
      'ins New before Configure/Call[#attribute/name = "addConnector"]',
      'set Configure/New/#attribute/id httpConfig',
      'set Configure/New[#attribute/id = "httpConfig"]/#attribute/class org.eclipse.jetty.server.HttpConfiguration',
      'set Configure/New[#attribute/id = "httpConfig"]/Call/#attribute/name addCustomizer',
      'set Configure/New[#attribute/id = "httpConfig"]/Call/Arg/New/#attribute/class org.eclipse.jetty.server.ForwardedRequestCustomizer',
    ],
    onlyif  => 'match Configure/New[#attribute/id = "httpConfig"] size == 0',
    require => Vcsrepo[$exist_home],
    notify  => Service['eXist-db'],
  }
}

define existdb::reverseproxy::server (
  $server_name = $title,
  $server_cert_name = $server_name,
  $ssl_cert = "/etc/pki/tls/certs/${server_cert_name}.crt", 
  $ss_key = "/etc/pki/tls/private/${server_cert_name}.key",
  $uri_path = '',
  $proxy_redirect = 'default',
) {
  include nginx
  nginx::resource::server { $server_name:
    proxy            => "http://127.0.0.1:8080${uri_path}",
    proxy_redirect   => $proxy_redirect,
    ssl              => true,
    ssl_redirect     => true,
    ssl_cert         => $ssl_cert,
    ssl_key          => $ssl_key,
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
}
