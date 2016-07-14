define certbot::renew ( $service = undef) {
  if($service == undef) {
    exec { 'certbot_renew':
      path    => '/usr/bin',
      command => "certbot renew -t -q",
    }
  } else {
    service { "stop $service":
      name    => $service,
      ensure  => stopped,
    }

    service { "start $service":
      name    => $service,
      ensure  => running,
    }

    exec { 'certbot_renew':
      path    => '/usr/bin',
      command => "certbot certonly --webroot -w $webroot -d $_domains -m $mail -t --agree-tos",
      require => Service["stop $service"],
      before  => Service["start $service"],
    }
  }
}
