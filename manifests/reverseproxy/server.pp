# configure a reverse proxy for an eXist-db server
define existdb::reverseproxy::server (
  $server_name = $title,
  $server_cert_name = $server_name,
  $ssl_cert_path = "/etc/pki/tls/certs/${server_cert_name}.crt",
  $ssl_cert = undef,
  $ssl_key_path = "/etc/pki/tls/private/${server_cert_name}.key",
  $ssl_key = undef,
  $uri_path = '',
  $location_cfg_append = undef,
  $location_custom_cfg_append = undef,
  $raw_append = undef,
) {
  include nginx

  if $uri_path != '' {
    $proxy_redirect = "https://${server_name}${uri_path} /"
  }
  else {
    $proxy_redirect = 'default'
  }

  nginx::resource::server { $server_name:
    proxy                      => "http://127.0.0.1:8080${uri_path}",
    proxy_redirect             => $proxy_redirect,
    ssl                        => true,
    ssl_redirect               => true,
    ssl_cert                   => $ssl_cert_path,
    ssl_key                    => $ssl_key_path,
    proxy_set_header           => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Host $host',
      'X-Forwarded-Proto $scheme',
      'Proxy ""',
    ],
    require                    => Class['existdb'],
    location_cfg_append        => $location_cfg_append,
    location_custom_cfg_append => $location_custom_cfg_append,
    raw_append                 => $raw_append,
  }

  if $ssl_cert {
    file { $ssl_cert_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $ssl_cert,
    }
  }

  if $ssl_key {
    file { $ssl_key_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $ssl_key,
    }
  }
}
