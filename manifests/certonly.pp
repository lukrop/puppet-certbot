define certbot::certonly (
  $webroot,
  $mail           = undef,
  $domains        = [],
  $renew_cron     = Hash[String, Integer, 2],
  $force_renewal  = false,
  #$cert_path      = undef,
  #$key_path       = undef,
  #$chain_path     = undef,
  #$fullchain_path = undef,
) {
  $_domains = join($domains, " -d ")
  $main_domain = $domains[0]

  #$mytemplate = template('certbot/certbot_cmd.erb')
  #notify { "check $title": message => $mytemplate }
  exec { "certbot_certonly_webroot $main_domain":
    path    => '/usr/bin',
    command => template('certbot/certbot_cmd.erb'),
    creates => "/etc/letsencrypt/renewal/$main_domain.conf",
  }

  if is_hash($renew_cron) {
    if !defined(Cron['certbot_renew']) {
      cron { 'certbot_renew':
        ensure  => present,
        hour    => $renew_cron[hour],
        minute  => $renew_cron[minute],
        command => "/usr/bin/certbot renew -q -t --agree-tos",
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
