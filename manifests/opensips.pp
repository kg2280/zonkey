class zonkey::opensips (

) inherits zonkey::params {
  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'perl-ExtUtils-Embed','perl-RPC-XML','perl-XMLRPC-Lite','perl-libapreq2','perl-JSON','perl-Redis','perl-Apache-Session-Redis','redis','hiredis','perl','perl-SOAP-Lite','bison','lynx','flex','modulis-opensips' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  
}
