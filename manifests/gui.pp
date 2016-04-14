class zonkey::gui (
  $db_user_user =		$zonkey::params::db_user_user,
  $db_user_pass = 		$zonkey::params::db_user_pass,
  $db_host =			$zonkey::params::db_host,
  $db_port =			$zonkey::params::db_port,
  $db_name =			$zonkey::params::db_name,
  $gui_base_domain =		$zonkey::params::gui_base_domain,
  $gui_root_user =		$zonkey::params::gui_root_user,
  $gui_root_pass =		$zonkey::params::gui_root_pass,
  $gui_passenger_version =	$zonkey::params::gui_passenger_version,
  $gui_ruby_version =		$zonkey::params::gui_ruby_version,
  $gui_gems_path =		$zonkey::params::gui_gems_path,
  $gui_deploy_rake =		$zonkey::params::gui_deploy_rake,

) inherits zonkey::params {
  $ip = $::ipaddress
  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'tftp-server','mariadb-devel','mysql++-devel','libxml2-devel','libicu-devel','httpd','httpd-devel','libcurl-devel','libapreq2-devel','ImageMagick-devel','apr-devel','apr-util-devel','sox','mod_ssl','gmp-devel','modulis-zonkey','sqlite-devel','xinetd','mariadb' ] 
      $ruby_update_path = "/usr/bin/update_rubygems"
      $apache_user = "apache"
      $apache_log = "/var/log/httpd"
      $apache_service = "httpd"
      $gems_path = "/var/lib64/gems"
    }
    'Debian', 'Ubuntu': { 
      $package = [ 'tftpd-hpa','libmariadbd-dev','libmysql++-dev','libxml2-dev','libicu-dev','apache2','apache2-dev','libcurl4-gnutls-dev','libsqlite3-dev','libssl-dev','graphicsmagick-libmagick-dev-compat','libmagickwand-dev','ruby-all-dev','libapr1-dev','libaprutil1-dev','libapreq2-3','libapreq2-dev','xinetd','sox','lame','openssl','modulis-zonkey' ]
      $ruby_update_path = "/usr/local/bin/update_rubygems"
      $apache_user = "www-data"
      $apache_log = "/var/log/apache2"
      $apache_service = "apache2"
      $gems_path = "/var/lib/gems"
    }
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
      file { ['/var/log/apache2','/var/log/apache2/zonkey','/etc/zonkey/bin','/etc/zonkey' ]:
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
    command => "$ruby_update_path && /usr/bin/touch /root/.rubygems.updated.do.not.delete.for.puppet",
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
        command => '/usr/bin/apt-get install -y g++ make && /usr/local/bin/passenger-install-apache2-module -a --languages ruby && /usr/bin/apt-get remove g++ make -y && touch /var/www/passenger.apache2modules.installed.do.not.delete.for.puppet',
	require => Package['passenger'],
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
      } ->
      exec { 'activate_zonkey_website':
        creates => "/etc/apache2/.zonkey.activated.do.not.remove.for.puppet",
        command => "/usr/sbin/a2ensite zonkey && /usr/sbin/a2dissite 000-default && /usr/bin/touch /etc/apache2/.zonkey.activated.do.not.remove.for.puppet",
        notify => Service['apache2'],
      }
    }
  } ->      
  file { '/etc/zonkey/bin/http_logger':
    source => 'puppet:///modules/zonkey/http_logger',
    owner => 'root', group => 'root',
    mode => 0750,
  } ->
  service { [$apache_service,'xinetd']:
    ensure => 'running',
  } ->
  file { '/etc/logrotate.d/httpd':
    source => 'puppet:///modules/zonkey/httpd',
    owner => 'root', group => 'root',
    mode => 0750,
  } ->
  file { '/var/www/zonkey/config/database.yml':
    content => template("zonkey/database.yml.erb"),
    require => Package['modulis-zonkey'],
    owner => "$apache_user", group => "$apache_user",
    mode => 0640
  }
  if $gui_deploy_rake {
    file { '/var/www/zonkey/rakeDeployConfig.expect':
      content => template("zonkey/rakeDeployConfig.expect.erb"),
      require => File['/var/www/zonkey/config/database.yml'],
      owner => "$apache_user", group => 'root',
      mode => 0755,
    }
    case $::operatingsystem {
      'CentOS', 'RedHat': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
      }
      'Debian', 'Ubuntu': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/apt-get install -y expect git patch gcc g++ make && /usr/local/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/apt-get remove gcc g++ expect make -y && chown -R www-data. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
      }
    }
  }
  else {
    case $::operatingsystem {
      'CentOS', 'RedHat': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
      }
      'Debian', 'Ubuntu': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/apt-get install -y expect git patch gcc g++ && /usr/local/bin/bundle install --without development test && bundle exec rake assets:precompile && /usr/bin/apt-get remove gcc g++ expect -y && chown -R www-data. /var/www && touch /var/www/zonkey/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
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
