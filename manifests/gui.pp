class zonkey::gui (
  $db_root_pass = 		$zonkey::params::db_root_pass,
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
  $ami_user =			$zonkey::params::ami_user,
  $ami_pass = 			$zonkey::params::ami_pass,
  $ami_host =			$zonkey::params::ami_host,
  $ami_sccp_host =		$zonkey::params::ami_sccp_host,
  $ami_queue_host =		$zonkey::params::ami_queue_host,
  $opensips_ip = 		$zonkey::params::opensips_ip,
  $opensips_port =              $zonkey::params::opensips_port,


) inherits zonkey::params {

  validate_string($db_root_pass)
  validate_string($db_user_user)
  validate_string($db_user_pass)
  validate_string($db_host)
  validate_numeric($db_port,65535,1)
  validate_string($db_name)
  validate_string($gui_base_domain)
  validate_string($gui_root_user)
  validate_string($gui_root_pass)
  validate_string($gui_passenger_version)
  validate_string($gui_ruby_version)
  validate_string($gui_gems_path)
  validate_bool($gui_deploy_rake)
  validate_string($ami_user)
  validate_string($ami_pass)
  validate_string($ami_permit)
  validate_array($ami_host)
  validate_array($ami_sccp_host)
  validate_array($ami_queue_host)
  validate_array($opensips_ip)
  validate_numeric($opensips_port,65535,1)
  

  $ip = $::ipaddress
  $db_ips[0] = $db_host

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
      $package = [ 'tftpd-hpa','libmariadbd-dev','libmysql++-dev','libxml2-dev','libicu-dev','apache2','apache2-dev','libcurl4-gnutls-dev','libsqlite3-dev','libssl-dev','graphicsmagick-libmagick-dev-compat','libmagickwand-dev','ruby-all-dev','libapr1-dev','libaprutil1-dev','libapreq2-3','libapreq2-dev','xinetd','sox','lame','openssl','modulis-zonkey','mariadb-client' ]
      $ruby_update_path = "/usr/local/bin/update_rubygems"
      $mariadb_client = "mariadb-client"
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
  exec { 'install_zonkey_gem':
    creates => '/root/.install.zonkey.gem.done.do.not.delete.for.puppet',
    command => "bash --login -c 'rvm install ruby 2.1.8 && rvm install ruby $gui_ruby_version && rvm use ruby $gui_ruby_version && gem install -v 5.0.30 passenger && gem install rubygems-update && gem install bundle && update_rubygems && rvm use ruby 2.1.8' && /usr/bin/touch /root/.install.zonkey.gem.done.do.not.delete.for.puppet",
    path => ["/usr/local/rvm/bin/","/usr/bin/","/bin/","/usr/local/rvm/gems/ruby-$gui_ruby_version/bin"],
  }
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
        command => "/usr/bin/apt-get install -y g++ make && bash --login -c 'rvm use ruby $gui_ruby_version && passenger-install-apache2-module -a --languages ruby && apt-get remove g++ make -y && rvm use 2.1.8' && touch /var/www/passenger.apache2modules.installed.do.not.delete.for.puppet",
	require => Exec['install_zonkey_gem'],
        path => ["/usr/local/rvm/gems/ruby-$gui_ruby_version/bin/","/usr/local/bin/","/usr/bin/","/usr/local/rvm/bin/","/bin/","/usr/bin/"],
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
          creates => '/root/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /root/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
      }
      'Debian', 'Ubuntu': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/root/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/apt-get install -y expect git patch gcc g++ make && bash --login -c 'rvm use ruby $gui_ruby_version && cd /var/www/zonkey && bundle install --without development test && /var/www/zonkey/rakeDeployConfig.expect && bundle exec rake assets:precompile && rvm use ruby 2.1.8' && /usr/bin/apt-get remove gcc g++ expect make -y && chown -R www-data. /var/www && touch /root/.zonkey.deployed.do.not.delete.for.puppet",
          require => [ File['/var/www/zonkey/rakeDeployConfig.expect'],Exec['create-db'] ],
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
          creates => '/root/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /root/.zonkey.deployed.do.not.delete.for.puppet",
          require => File['/var/www/zonkey/rakeDeployConfig.expect'],
          timeout => 0,
        }
      }
      'Debian', 'Ubuntu': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/root/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/apt-get install -y expect git patch gcc g++ && bash --login -c 'rvm use ruby $gui_ruby_version && cd /var/www/zonkey && bundle install --without development test && bundle exec rake assets:precompile && rvm use ruby 2.1.8' && /usr/bin/apt-get remove gcc g++ expect -y && chown -R www-data. /var/www && touch /root/.zonkey.deployed.do.not.delete.for.puppet",
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
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
    require => Package[$mariadb_client],
  }
  file { "/etc/zonkey/config/asterisk-ajam.yml":
    owner => "root", group => "www-data",
    mode => 0640,
    content => template("zonkey/asterisk-ajam.yml.erb"),
    require => Package["modulis-zonkey"],
  }
  file { "/etc/zonkey/config/opensips.yml":
    owner => "root", group => "www-data",
    mode => 0640,
    content => template("zonkey/opensips.yml.erb"),
    require => Package["modulis-zonkey"],
  }
}
