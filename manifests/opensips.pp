class zonkey::opensips (
  $opensips_listen_interface =	$zonkey::params::opensips_listen_interface,
  $opensips_port =		$zonkey::params::opensips_port,
  $opensips_ip =		$zonkey::params::opensips_ip,
  $opensips_base_domain  =	$zonkey::params::opensips_base_domain,
  $db_root_pass =		$zonkey::params::db_root_pass,
  $db_user_user =		$zonkey::params::db_user_user,
  $db_user_pass =		$zonkey::params::db_user_pass,
  $db_host =			$zonkey::params::db_host,
  $db_name =			$zonkey::params::db_name,
  $gui_ip =			$zonkey::params::gui_ip,
  $opensips_skinny_ip =		$zonkey::params::opensips_skinny_ip,
  $opensips_floating_ip =	$zonkey::params::opensips_floating_ip,
  $legacy_server =		$zonkey::params::legacy_server,

) inherits zonkey::params {

  validate_string($db_user_user)
  validate_string($db_user_pass)
  validate_string($db_host)
  validate_string($db_name)
  validate_array($opensips_ip)
  validate_string($opensips_base_domain)
  validate_numeric($opensips_port, 55636, 1)
  validate_string($opensips_floating_ip)

  $db_ips[0] = $db_host
  $ip = $::ipaddress
  $fqdn = $::fqdn

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'perl-ExtUtils-Embed','perl-RPC-XML','perl-XMLRPC-Lite','perl-libapreq2','perl-JSON','perl-Redis','perl-Apache-Session-Redis','redis','hiredis','perl','perl-SOAP-Lite','bison','lynx','flex','modulis-opensips','mariadb','libmicrohttpd-devel' ] 
      $redis_service = "redis"
    }
    'Debian', 'Ubuntu': { 
      $package = [ 'perl-modules','librpc-xml-perl','libxmlrpc-lite-perl','libapreq2-3','libapreq2-dev','libjson-perl','libredis-perl','libapache-session-perl','redis-server','libhiredis0.10','perl','libsoap-lite-perl','bison','lynx','flex','opensips','mysql-client','libmicrohttpd-dev','modulis-opensips-conf','opensips-b2bua-module','opensips-carrierroute-module','opensips-console','opensips-cpl-module','opensips-dbg','opensips-dbhttp-module','opensips-dialplan-module','opensips-geoip-module','opensips-http-modules','opensips-identity-module','opensips-jabber-module','opensips-json-module','opensips-ldap-modules','opensips-lua-module','opensips-memcached-module','opensips-mysql-module','opensips-perl-modules','opensips-postgres-module','opensips-presence-modules','opensips-rabbitmq-module','opensips-radius-modules','opensips-redis-module','opensips-regex-module','opensips-restclient-module','opensips-snmpstats-module','opensips-unixodbc-module','opensips-xmlrpcng-module','opensips-xmlrpc-module','opensips-xmpp-module' ] 
      $redis_service = "redis-server"
    }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  file { '/etc/zonkey/opensips/modules_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/modules_params.cfg.erb'),
    require => Package['modulis-opensips-conf'],
    notify => Service['opensips'],
  }
  file { '/etc/zonkey/opensips/global_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/global_params.cfg.erb'),
    require => Package['modulis-opensips-conf'],
    notify => Service['opensips'],
  }
  file { '/etc/zonkey/opensips/shared_vars.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/shared_vars.cfg.erb'),
    require => Package['modulis-opensips-conf'],
    notify => Service['opensips'],
  }
  file { '/etc/opensips/opensipsctlrc':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/opensipsctlrc.erb'),
    require => Package['opensips'],
  }
  service { $redis_service:
    ensure => 'running',
    enable => true,
  }
  service { 'opensips':
    ensure => 'running',
    enable => true,
    require => Service[$redis_service],
  }
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
  }
  if $opensips_floating_ip != "127.0.0.1" {
    exec { 'sysctl.non.local.bind':
      creates => '/root/.non.local.bind.do.not.delete.for.puppet"',
      path => '/usr/bin',
      command => 'echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf && touch "/root/.non.local.bind.do.not.delete.for.puppet"',
      notify => Service['opensips'],
    }
  }
  service { "rsyslog":
    ensure => "running",
    enable => "true",
  }
  exec { "add_opensips_to_rsyslog":
    unless => "/bin/grep 'local5.* -/var/log/opensips/opensips.log' /etc/rsyslog.conf",
    command => "/bin/echo 'local5.* -/var/log/opensips/opensips.log' >> /etc/rsyslog.conf",
    notify => Service['rsyslog'],    
  }
  exec { "no_opensips_to_messages":
    unless => "/bin/grep 'local5.none -/var/log/messages' /etc/rsyslog.conf",
    command => "/bin/echo 'local5.none -/var/log/messages' >> /etc/rsyslog.conf",
    notify => Service['rsyslog'],    
  }
  file { 'opensips.logrot':
    ensure => 'present',
    path => '/etc/logrotate.d/opensips',
    source => 'puppet:///modules/zonkey/opensips.logrot',
    owner => 'root',
    group => 'root',
    mode => 0644,
  }
}

