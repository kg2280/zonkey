class zonkey::asterisksccp (
  $db_host =			$zonkey::params::db_host,
  $db_name =			$zonkey::params::db_name,
  $db_root_pass =		$zonkey::params::db_root_pass,
  $db_user_user =		$zonkey::params::db_user_user,
  $db_user_pass =		$zonkey::params::db_user_pass,
  $ast_realm =			$zonkey::params::ast_realm,
) inherits zonkey::params {

  validate_string($ast_db_host)
  validate_string($ast_db_name)
  validate_string($ast_db_user)
  validate_string($ast_db_pass)
  validate_string($ast_realm)

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'mysql-connector-odbc','modulis-dahdi-complete','modulis-cert-asterisk-sccp','mariadb','modulis-chan-sccp-stable' ]  
      $mariadb_client = mariadb
    }
    /^(Debian|Ubuntu)$/: { 
      $package = ['modulis-dahdi','mariadb-client','modulis-cert-asterisk-sccp','modulis-sccp-driver' ]  
      $mariadb_client = mariadb-client
    }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package']
  }
  file { '/etc/zonkey/asterisk/extensions_global.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/extensions_global.sccp.conf.erb'),
    require => Package['modulis-cert-asterisk-sccp'],
    notify => Service['asterisk'],
  }
  file { '/etc/odbc.ini':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/odbc.ini.erb'),
    require => Package['modulis-cert-asterisk-sccp'],
    notify => Service['asterisk'],
  }
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
    require => Package[$mariadb_client],
  } ->
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      file { '/usr/lib/systemd/system/asterisk.service':
        owner => 'root', group => 'root',
        mode => 0640,
        source => 'puppet:///modules/zonkey/asterisk.service',
        require => Package['modulis-cert-asterisk-sccp'],
      }
      service { 'asterisk':
        ensure => 'running',
        enable => true,
        require => File['/usr/lib/systemd/system/asterisk.service'],
      }
    }
    'Debian', 'Ubuntu': {
      service { 'asterisk':
        ensure => 'running',
        enable => true,
      }
    }
  }
}
