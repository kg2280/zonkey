class zonkey::asterisksccp (
  $db_host =			$zonkey::params::db_host,
  $db_name =			$zonkey::params::db_name,
  $db_root_pass =		$zonkey::params::db_root_pass,
  $db_user_user =		$zonkey::params::db_user_user,
  $db_user_pass =		$zonkey::params::db_user_pass,
  $sccp_realm =			$zonkey::params::sccp_realm,
  $default_lang = 		$zonkey::params::default_lang,
  $ami_user =                   $zonkey::params::ami_user,
  $ami_pass =                   $zonkey::params::ami_pass,
  $ami_permit =                 $zonkey::params::ami_permit,

) inherits zonkey::params {

  validate_string($db_host)
  validate_string($db_name)
  validate_string($db_user)
  validate_string($db_pass)
  validate_string($sccp_realm)
  validate_string($default_lang)

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'mysql-connector-odbc','modulis-dahdi-complete','modulis-cert-asterisk-sccp','mariadb','modulis-chan-sccp-stable' ]  
      $mariadb_client = mariadb
    }
    /^(Debian|Ubuntu)$/: { 
      $package = ['modulis-dahdi','mariadb-client','modulis-cert-asterisk-sccp','modulis-sccp-driver','libwww-perl','libparallel-forkmanager-perl','libanyevent-perl','libdbd-mysql-perl','libredis-perl','libjson-perl','binutils-multiarch-dev' ]  
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
  file { '/etc/zonkey/asterisk/zonkey.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/zonkey.conf.sccp.erb'),
    require => Package['modulis-cert-asterisk-sccp'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/manager_custom.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/manager_custom.conf.erb'),
    require => Package['modulis-cert-asterisk-sccp'],
    notify => Service['asterisk'],
  }
  file { '/etc/asterisk/manager.conf':
    ensure => 'present',
    owner => "root", group => "asterisk",
    mode => 0640,
    source => 'puppet:///modules/zonkey/manager.conf',
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
  exec { "populate_database":
    creates => '/root/.populate.mysql.do.not.delete.for.puppet',
    path => "/usr/bin/",
    command => "mysql -u $db_user_user -p$db_user_pass -h $db_host -e \"insert into zonkey.routing_gateways set realm_id = 0, type=11, address = '$::ipaddress', description = '$::hostname', created_at = now(), updated_at = now(); update zonkey.routing_gateways set gwid=id where address='$::ipaddress'\" && touch /root/.populate.mysql.do.not.delete.for.puppet",
    require => File['/root/.my.cnf'],
  }
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
  exec { "cp_odbcinst":
    unless => "ls /etc/odbcinst.ini",
    command => "cp /usr/share/libmyodbc/odbcinst.ini /etc/",
    require => Package['libmyodbc'],
  }
}
