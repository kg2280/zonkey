class zonkey::db (
  $root_pass		=> $zonkey::params::root_pass
  $zonkey_user		=> $zonkey::params::zonkey_user
  $zonkey_pass		=> $zonkey::params::zonkey_pass
  $ip_db1		=> $zonkey::params::ip_db1
  $ip_db2		=> $zonkey::params::ip_db2

) inherits zonkey::params {

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mysql++','mariadb-server','mariadb','libiodbc' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['epel'],
    require => File['modulis.repo'],
  }
  

}
