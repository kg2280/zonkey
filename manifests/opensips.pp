class zonkey::opensips (
  $opensips_listen_interface =	$zonkey::params::opensips_listen_interface,
  $opensips_port =		$zonkey::params::opensips_port,
  $opensips_ip =		$zonkey::params::opensips_ip,
  $opensips_base_domain  =	$zonkey::params::opensips_base_domain,
  $opensips_db_user =		$zonkey::params::opensips_db_user,
  $opensips_db_pass =		$zonkey::params::opensips_db_pass,
  $opensips_db_host =		$zonkey::params::opensips_db_host,
  $opensips_db_name =		$zonkey::params::opensips_db_name,
  $opensips_mgm_ip =		$zonkey::params::opensips_mgm_ip,
  $opensips_skinny_ip =		$zonkey::params::opensips_skinny_ip,
) inherits zonkey::params {

  validate_string($opensips_db_user)
  validate_string($opensips_db_pass)
  validate_string($opensips_db_host)
  validate_string($opensips_db_name)
  validate_array($opensips_ip)
  validate_string($opensips_base_domain)
  validate_numeric($opensips_port, 55636, 1)

  $ip1 = $opensips_ip[0]
  $ip2 = $opensips_ip[1]
  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'perl-ExtUtils-Embed','perl-RPC-XML','perl-XMLRPC-Lite','perl-libapreq2','perl-JSON','perl-Redis','perl-Apache-Session-Redis','redis','hiredis','perl','perl-SOAP-Lite','bison','lynx','flex','modulis-opensips' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  file { '/etc/zonkey/opensips/modules_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/modules_params.cfg.erb'),
    require => Package['modulis-opensips'],
  }
  file { '/etc/zonkey/opensips/global_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/global_params.cfg.erb'),
    require => Package['modulis-opensips'],
  }
  file { '/etc/zonkey/opensips/shared_vars.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/shared_vars.cfg.erb'),
    require => Package['modulis-opensips'],
  }
  file { '/opt/opensips/etc/opensips/opensipsctlrc':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/opensipsctlrc.erb'),
    require => Package['modulis-opensips'],
  }
  
}
