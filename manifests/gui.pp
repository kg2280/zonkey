class zonkey::gui (
  $gui_db_user =	$zonkey::params::gui_db_user,
  $gui_db_pass = 	$zonkey::params::gui_db_pass,
  $gui_db_host =	$zonkey::params::gui_db_host,
  $gui_db_port =	$zonkey::params::gui_db_port,
  $gui_db_name =	$zonkey::params::gui_db_name,
  $gui_base_domain =	$zonkey::params::gui_base_domain,
  $gui_root_user =	$zonkey::params::gui_root_user,
  $gui_root_pass =	$zonkey::params::gui_root_pass,

) inherits zonkey::params {
  $ip = $::ipaddress

  case $::operatingsystem {
    'RedHat', 'CentOS': { $package = [ 'tftp-server','curl','mariadb-devel','mysql++-devel','libxml2-devel','libicu-devel','httpd','httpd-devel','libcurl-devel','libapreq2-devel','ImageMagick-devel','apr-devel','apr-util-devel','sox','mod_ssl','gmp-devel','modulis-zonkey','sqlite-devel','xinetd' ] }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  } ->
  file { ['/var/log/httpd','/var/log/httpd/zonkey','/etc/zonkey/bin','/etc/zonkey' ]:
    ensure => 'directory',
    owner => 'apache', group => 'apache',
    mode => 0770
  } ->
  exec { 'update_rubygems':
    creates => '/root/.rubygems.updated.do.not.delete.for.puppet',
    command => '/usr/bin/gem install rubygems-update; rubygems-update; touch /root/.rubygems.updated.do.not.delete.for.puppet',
  } ->
  package { ['bundle','passenger']:
    ensure => 'installed',
    provider => 'gem',
  } ->
  exec { 'install-apache2-modules':
    creates => '/var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
    command => '/usr/bin/yum install -y gcc-c++ && /usr/bin/passenger-install-apache2-module -a --languages ruby && /usr/bin/yum remove gcc-c++ -y && touch /var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
  } ->
  file { 'ssl.conf':
    ensure => 'present',
    path => '/etc/httpd/conf.d/ssl.conf',
    owner => "root", group => "root",
    mode => 0640,
    source => 'puppet:///modules/zonkey/ssl.conf',
    require => Package["httpd"],
    notify => Service['httpd'],
  } ->
  file { 'zonkey.conf':
    path => '/etc/httpd/conf.d/zonkey.conf',
    owner => 'root', group => 'root',
    mode => 0640,
    content => template("zonkey/zonkey.conf.erb"),
    require => Package["httpd"],
    notify => Service['httpd'],
  } ->  
  file { '/etc/zonkey/bin/http_logger':
    source => 'puppet:///modules/zonkey/http_logger',
    owner => 'root', group => 'root',
    mode => 0750,
  } ->
  service { ['httpd','xinetd']:
    ensure => 'running',
  } ->
  file { '/etc/logrotate.d/httpd':
    source => 'puppet:///modules/zonkey/httpd',
    owner => 'root', group => 'root',
    mode => 0750,
  } ->
  file { '/var/www/zonkey/config/database.yml':
    content => template("zonkey/database.yml.erb"),
    require => Package["modulis-zonkey"],
    owner => 'apache', group => 'root',
    mode => 0640
  } ->
  file { '/var/www/zonkey/rakeDeployConfig.expect':
    content => template("zonkey/rakeDeployConfig.expect.erb"),
    require => Package["modulis-zonkey"],
    owner => 'apache', group => 'root',
    mode => 0755
  } ->
  exec { 'deploy-zonkey':
  cwd => '/var/www/zonkey',
  creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
  command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
  }
  file { '/etc/xinetd.d/tftp':
  source => 'puppet:///modules/zonkey/tftp',
  owner => 'root', group => 'root',
  mode => 0640,
  require => Package['xinetd'],
  notify => Service['xinetd'],
  }  
}
