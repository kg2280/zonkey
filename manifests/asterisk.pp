class zonkey::asterisk (
  $ast_ip =			$zonkey::params::ast_ip,
  $ast_db_host =		$zonkey::params::ast_db_host,
  $ast_db_name =		$zonkey::params::ast_db_name,
  $ast_db_user =		$zonkey::params::ast_db_user,
  $ast_db_pass =		$zonkey::params::ast_db_pass,
  $ast_db_cdrs_table =		$zonkey::params::ast_db_cdrs_table,
  $ast_port = 			$zonkey::params::ast_port,
  $ast_opensips_ip = 		$zonkey::params::ast_opensips_ip,
  $ast_opensips_port = 		$zonkey::params::ast_opensips_port,
  $ast_mgm01_ip = 		$zonkey::params::ast_mgm01_ip,
  $ast_default_lang =		$zonkey::params::ast_default_lang,
  $ast_directmedia = 		$zonkey::params::ast_directmedia,
  $ast_notification_email = 	$zonkey::params::ast_notification_email,
  $ast_rtp_port =		$zonkey::params::ast_rtp_port,
  $ast_skinny = 		$zonkey::params::ast_skinny,
  $ast_lang =			$zonkey::params::ast_lang,

) inherits zonkey::params {

  validate_string($ast_ip)
  validate_string($ast_db_host)
  validate_string($ast_db_name)
  validate_string($ast_db_user)
  validate_string($ast_db_pass)
  validate_string($ast_db_cdrs_table)
  validate_numeric($ast_port,65535,1)
  validate_string($ast_opensips_ip)
  validate_numeric($ast_opensips_port,65535,1)
  validate_string($ast_mgm01_ip)
  validate_string($ast_default_lang)
  validate_bool($ast_directmedia)
  validate_string($ast_notification_email)
  validate_array($ast_rtp_port)
  validate_bool($ast_skinny)

  $rtp_port_start = $ast_rtp_port[0]
  $rtp_port_end = $ast_rtp_port[1]

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mysql-connector-odbc','modulis-dahdi-complete','modulis-cert-asterisk','mariadb' ]  }
    /^(Debian|Ubuntu)$/:{ $package = ['mariadb-client','modulis-cert-asterisk','modulis-dahdi' ]  }
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

}
