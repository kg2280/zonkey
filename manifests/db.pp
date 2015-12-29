class zonkey::db (
  $db_name		= $zonkey::params::db_name,
  $db_root_pass		= $zonkey::params::db_root_pass,
  $db_user_user		= $zonkey::params::db_zonkey_user,
  $db_user_pass		= $zonkey::params::db_zonkey_pass,
  $ip_db		= $zonkey::params::ip_db,
  
) inherits zonkey::params {

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mariadb-server','mariadb','libiodbc' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  service { 'mariadb':
    ensure => 'running',
  }
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
    require => Package["mariadb-server"],
  }
  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$db_root_pass status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $db_root_pass",
    require => Service["mariadb"],
  }
  exec { "create-db":
    unless => "/usr/bin/mysql -uroot -p$db_root_pass db_name",
    command => "/usr/bin/mysql -uroot -p$db_root_pass -e \"create database $db_name; grant all on $db_name.* to $db_user_user@localhost identified by '$db_user_pass';\"",
    require => Service["mariadb"],
  }
  

}
