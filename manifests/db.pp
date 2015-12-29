class zonkey::db (
  $db_name		= $zonkey::params::db_name,
  $drop_db		= $zonkey::params::drop_db,
  $db_root_pass		= $zonkey::params::db_root_pass,
  $db_user_user		= $zonkey::params::db_user_user,
  $db_user_pass		= $zonkey::params::db_user_pass,
  $ip_db		= $zonkey::params::ip_db,
  $from_network		= $zonkey::params::from_network
  
) inherits zonkey::params {
  validate_string($db_name)
  validate_string($drop_db)
  validate_string($db_root_pass)
  validate_string($db_user_user)
  validate_string($db_user_pass)
  validate_array($ip_db)
  validate_string($from_network)

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mariadb-server','mariadb','libiodbc' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  } ->
  service { 'mariadb':
    ensure => 'running',
  } ->
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
    require => Package["mariadb-server"],
  } ->
  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$db_root_pass status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $db_root_pass",
    require => Service["mariadb"],
  } ->
  exec { "drop-db":
    onlyif => "/usr/bin/test -d /var/lib/mysql/$drop_db",
    command => "/usr/bin/mysql -uroot -p$db_root_pass -e \"drop database $drop_db; delete from mysql.user where user='' or password='' or host='';\"",
    require => Service["mariadb"],
  } ->
  exec { "create-db":
    unless => "/usr/bin/test -d /var/lib/mysql/$db_name",
    command => "/usr/bin/mysql -uroot -p$db_root_pass -e \"create database $db_name; grant all privileges on $db_name.* to '$db_user_user'@'$from_network' identified by '$db_user_pass'; grant super on *.* to '$db_user_user'@'$from_network' identified by '$db_user_pass'; grant all privileges on *.* to 'root'@'$from_network' identified by '$db_root_pass' with grant option; grant super on *.* to 'root'@'$from_network' identified by '$db_root_pass'; flush privileges\"",
    require => Service["mariadb"],
  }
  

}
