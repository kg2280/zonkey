class zonkey::asterisk (
  $redundancy = $zonkey::params::redundancy,
  $mysql_ip = $zonkey::params::mysql_ip,
  $asterisk_port = $zonkey::params::asterisk_port,
  $opensips_port = $zonkey::params::opensips_port,

){

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'mysql-connector-odbc','mariadb','dahdi-linux-complete','certified-asterisk-11.6' ]  }
    /^(Debian|Ubuntu)$/:{ $package = ['manpages','wget','curl','nano','openvpn' ]  }
  }

  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package']
  }

  

}
