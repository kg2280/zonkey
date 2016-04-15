class zonkey::asterisk (
  $ast_resources =		$zonkey::params::ast_resources,
  $db_host =			$zonkey::params::db_host,
  $db_name =			$zonkey::params::db_name,
  $db_root_pass =		$zonkey::params::db_root_pass,
  $db_user_user =		$zonkey::params::db_user_user,
  $db_user_pass =		$zonkey::params::db_user_pass,
  $ast_cdrs_table =		$zonkey::params::ast_cdrs_table,
  $ast_port = 			$zonkey::params::ast_port,
  $opensips_ip = 		$zonkey::params::opensips_ip,
  $opensips_floating_ip =	$zonkey::params::opensips_floating_ip,
  $opensips_port = 		$zonkey::params::opensips_port,
  $gui_ip =	 		$zonkey::params::gui_ip,
  $default_lang =		$zonkey::params::default_lang,
  $ast_directmedia = 		$zonkey::params::ast_directmedia,
  $ast_notification_email = 	$zonkey::params::ast_notification_email,
  $ast_rtp_port =		$zonkey::params::ast_rtp_port,
  $ast_skinny = 		$zonkey::params::ast_skinny,
  $ami_user =			$zonkey::params::ami_user,
  $ami_pass =			$zonkey::params::ami_pass,
  $ami_permit =			$zonkey::params::ami_permit,

) inherits zonkey::params {

  validate_string($ast_resources)
  validate_string($ast_db_host)
  validate_string($ast_db_name)
  validate_string($ast_db_user)
  validate_string($ast_db_pass)
  validate_string($ast_cdrs_table)
  validate_numeric($ast_port,65535,1)
  validate_array($opensips_ip)
  validate_numeric($opensips_port,65535,1)
  validate_string($gui_ip_ip)
  validate_string($default_lang)
  validate_bool($ast_directmedia)
  validate_string($ast_notification_email)
  validate_array($ast_rtp_port)
  validate_bool($ast_skinny)

  $rtp_port_start = $ast_rtp_port[0]
  $rtp_port_end = $ast_rtp_port[1]
  $db_ips[0] = $db_host

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mysql-connector-odbc','modulis-dahdi-complete','modulis-cert-asterisk','mariadb' ]  }
    /^(Debian|Ubuntu)$/:{ $package = ['mariadb-client','modulis-cert-asterisk','modulis-dahdi','libwww-perl','libparallel-forkmanager-perl','libanyevent-perl','libdbd-mysql-perl','libredis-perl','libjson-perl' ]  }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package']
  }
  file { '/etc/zonkey/asterisk/cdr_mysql.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/cdr_mysql.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/extensions_global.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/extensions_global.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/sip_general_custom.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/sip_general_custom.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/sip_static.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/sip_static.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/zonkey.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/zonkey.conf.ast.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/odbc.ini':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/odbc.ini.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/rtp_static.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/rtp_static.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      file { '/usr/lib/systemd/system/asterisk.service':
        owner => 'root', group => 'root',
        mode => 0640,
        source => 'puppet:///modules/zonkey/asterisk.service',
        require => Package['modulis-cert-asterisk'],
      }
      service { 'asterisk':
        ensure => 'running',
        enable => true,
        require => File['/usr/lib/systemd/system/asterisk.service'],
      }
    }
    'Debian','Ubuntu': {
      service { 'asterisk':
        ensure => 'running',
        enable => true,
      }
    }
  }
  file { '/etc/zonkey/asterisk/asterisk.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/asterisk.conf.erb'),
    require => Package['modulis-cert-asterisk'],
  }
  file { '/etc/zonkey/asterisk/voicemail_general.cfg':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/voicemail_general.cfg.erb'),
    require => Package['modulis-cert-asterisk'],
  }
  file { '/etc/zonkey/bin/externnotify.sh':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/externnotify.sh.erb'),
    require => Package['modulis-cert-asterisk'],
  }
  file { '/etc/asterisk/manager.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/manager.conf.erb'),
    require => Package['modulis-cert-asterisk'],
  }
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
  }
  exec { "populate_database":
    creates => '/root/.populate.mysql.do.not.delete.for.puppet',
    path => "/usr/bin/",
    command => "mysql -u $db_user_user -p$db_user_pass -h $db_host -e \"insert into zonkey.load_balancer (group_id, dst_uri, resources, probe_mode, description) VALUES (1, 'sip:$::ipaddress:$ast_port', '$ast_resources', 1, '$::hostname'); insert into zonkey.routing_gateways set realm_id = 0, type=10, address = '$::ipaddress', description = '$::hostname', created_at = now(), updated_at = now(); update zonkey.routing_gateways set gwid=id where address='$::ipaddress'\" && touch /root/.populate.mysql.do.not.delete.for.puppet",
    require => File['/root/.my.cnf'],
  }
}
