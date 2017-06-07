class existdb::reverseproxy (
  $server_name,
  $server_cert_name = $server_name,
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
      'set Configure/New[#attribute/id = "httpdConfig"]/#attribute/class org.eclipse.jetty.server.HttpConfiguration',
      'clear Configure/New[#attribute/id = "httpdConfig"]/Arg/New[#attribute/class = "org.eclipse.jetty.server.ForwardedRequestCustomizer"]',
      require => Class['existdb'],
      notify  => Service['eXist-db'],
    }
}
