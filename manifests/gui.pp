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
    'RedHat', 'CentOS': { $package = [ 'tftp-server','curl','mariadb-devel','mysql++-devel','libxml2-devel','libicu-devel','httpd','httpd-devel','libcurl-devel','libapreq2-devel','ImageMagick-devel','apr-devel','apr-util-devel','sox','mod_ssl','gmp-devel','modulis-zonkey','sqlite-devel','xinetd','mariadb' ] }
    'Debian', 'Ubuntu': { $package = [ 'tftpd-hpa','curl','libmariadbd-dev','libmysql++-dev','libxml2-dev','libicu-dev','apache2','apache2-dev','libcurl4-gnutls-dev','libsqlite3-dev','libssl-dev','graphicsmagick-libmagick-dev-compat','libmagickwand-dev','ruby-all-dev','libapr1-dev','libaprutil1-dev','libapreq2-3','libapreq2-dev','xinetd','sox','lame','openssl',ruby-full ]}
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  } ->
  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      file { ['/var/log/httpd','/var/log/httpd/zonkey','/etc/zonkey/bin','/etc/zonkey' ]:
        ensure => 'directory',
        owner => 'apache', group => 'apache',
        mode => 0770,
      }
    }
    'Debian', 'Ubuntu': { 
      file { ['/var/log/apache','/var/log/apache/zonkey','/etc/zonkey/bin','/etc/zonkey' ]:
        ensure => 'directory',
        owner => 'www-data', group => 'www-data',
        mode => 0770,
      }
    }
  } ->
  package { 'rubygems-update':
    ensure => latest,
    provider => 'gem',
  } ->
  exec { 'update_rubygems':
    creates => '/root/.rubygems.updated.do.not.delete.for.puppet',
    command => '/usr/bin/update_rubygems && /usr/bin/touch /root/.rubygems.updated.do.not.delete.for.puppet',
  } ->
  package { ['bundle','passenger']:
    ensure => 'installed',
    provider => 'gem',
  } ->
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      exec { 'install-apache2-modules':
        creates => '/var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
        command => '/usr/bin/yum install -y gcc-c++ && /usr/bin/passenger-install-apache2-module -a --languages ruby && /usr/bin/yum remove gcc-c++ -y && touch /var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
        timeout => 0,
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
      }
    }
    'Debian', 'Ubuntu': {
      exec { 'install-apache2-modules':
        creates => '/var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
        command => '/usr/bin/apt-get install -y g++ && /usr/bin/passenger-install-apache2-module -a --languages ruby && /usr/bin/apt-get remove g++ -y && touch /var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
        timeout => 0,
      } ->
      file { 'ssl.conf':
        ensure => 'present',
        path => '/etc/apache2/sites-available/ssl.conf',
        owner => "root", group => "root",
        mode => 0640,
        source => 'puppet:///modules/zonkey/ssl.conf',
        require => Package["apache2"],
        notify => Service['apache2'],
      } ->
      file { 'zonkey.conf':
        path => '/etc/apache2/sites-available/zonkey.conf',
        owner => 'root', group => 'root',
        mode => 0640,
        content => template("zonkey/zonkey.conf.erb"),
        require => Package["apache2"],
        notify => Service['apache2'],
      }
    }
  } ->      
  file { '/etc/zonkey/bin/http_logger':
    source => 'puppet:///modules/zonkey/http_logger',
    owner => 'root', group => 'root',
    mode => 0750,
  } ->
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      service { ['httpd','xinetd']:
        ensure => 'running',
      }
    }
    'Debian', 'Ubuntu': {
      service { ['apache2','xinetd']:
        ensure => 'running',
      }
    }
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
    mode => 0755,
  } ->
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      exec { 'deploy-zonkey':
        cwd => '/var/www/zonkey',
        creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
        command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
        timeout => 0,
      }
    }
    'Debian', 'Ubuntu': {
      exec { 'deploy-zonkey':
        cwd => '/var/www/zonkey',
        creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
        command => "/usr/bin/apt-get install -y expect git patch gcc g++ && /usr/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/apt-get remove gcc g++ expect -y && chown -R www-data. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
        timeout => 0,
      }
    }
  }
  file { '/etc/xinetd.d/tftp':
  source => 'puppet:///modules/zonkey/tftp',
  owner => 'root', group => 'root',
  mode => 0640,
  require => Package['xinetd'],
  notify => Service['xinetd'],
  }  
}
