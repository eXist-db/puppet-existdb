define existdb::reverseproxy::server (
  $server_name = $title,
  $server_cert_name = $server_name,
  $ssl_cert = "/etc/pki/tls/certs/${server_cert_name}.crt",
  $ssl_key = "/etc/pki/tls/private/${server_cert_name}.key",
  $uri_path = '',
  $location_cfg_append = undef,
) {
  include nginx

  if $uri_path != '' {
    $proxy_redirect = "https://${server_name}${uri_path} /"
  }
  else {
    $proxy_redirect = 'default'
  }

  nginx::resource::server { $server_name:
    proxy               => "http://127.0.0.1:8080${uri_path}",
    proxy_redirect      => $proxy_redirect,
    ssl                 => true,
    ssl_redirect        => true,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    proxy_set_header    => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Host $host',
      'X-Forwarded-Proto $scheme',
      'Proxy ""',
    ],
    require             => Class['existdb'],
    location_cfg_append => $location_cfg_append,
  }
}
