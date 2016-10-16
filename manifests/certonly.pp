define certbot::certonly (
  $webroot,
  $mail           = undef,
  $domains        = [],
  $renew_cron     = Hash[String, Integer, 2],
  $force_renewal  = false,
) {
  $_domains = join($domains, " -d ")
  $main_domain = $domains[0]


  if ($force_renewal) {
    exec { "certbot_certonly_webroot $main_domain":
      path    => '/usr/bin',
      command => template('certbot/certbot_cmd.erb'),
    }
  } else {
    exec { "certbot_certonly_webroot $main_domain":
      path    => '/usr/bin',
      command => template('certbot/certbot_cmd.erb'),
      creates => "/etc/letsencrypt/renewal/$main_domain.conf",
    }
  }

  if is_hash($renew_cron) {
    if !defined(Cron['certbot_renew']) {
      cron { 'certbot_renew':
        ensure  => present,
        hour    => $renew_cron[hour],
        minute  => $renew_cron[minute],
        command => '/usr/bin/certbot renew -q -t --agree-tos --post-hook "systemctl restart nginx.service"',
      }
    }
  } else {
    if !defined(Cron['certbot_renew']) {
      cron { 'certbot_renew':
        ensure  => absent,
      }
    }
  }
}
