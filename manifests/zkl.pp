class zonkey::zkl (
  $db_name =			$zonkey::params::db_name,
  $db_drop =			$zonkey::params::db_drop,
  $db_root_pass =		$zonkey::params::db_root_pass,
  $db_user_user	=		$zonkey::params::db_user_user,
  $db_user_pass	=		$zonkey::params::db_user_pass,
  $db_ips =			$zonkey::params::db_ips,
  $db_host =			$zonkey::params::db_host,
  $db_port =			$zonkey::params::db_port,
  $db_from_network =		$zonkey::params::db_from_network,
  $db_server_id =		$zonkey::params::db_server_id,
  $db_replication       = 	$zonkey::params::db_replication,
  $db_replication_pass  = 	$zonkey::params::db_replication_pass,
  $db_master_log_file   = 	$zonkey::params::db_master_log_file,
  $db_master_log_pos    = 	$zonkey::params::db_master_log_pos,

  $gui_base_domain =            $zonkey::params::gui_base_domain,
  $gui_root_user =              $zonkey::params::gui_root_user,
  $gui_root_pass =              $zonkey::params::gui_root_pass,
  $gui_passenger_version =      $zonkey::params::gui_passenger_version,
  $gui_ruby_version =           $zonkey::params::gui_ruby_version,
  $gui_gems_path =              $zonkey::params::gui_gems_path,
  $gui_ip =			$zonkey::params::gui_ip,
  $gui_deploy_rake =            $zonkey::params::gui_deploy_rake,

  $opensips_listen_interface =  $zonkey::params::opensips_listen_interface,
  $opensips_port =              $zonkey::params::opensips_port,
  $opensips_ip =                $zonkey::params::opensips_ip,
  $opensips_base_domain  =      $zonkey::params::opensips_base_domain,
  $opensips_skinny_ip =         $zonkey::params::opensips_skinny_ip,
  $opensips_floating_ip =	$zonkey::params::opensips_floating_ip,
  $legacy_server =		$zonkey::params::legacy_server,
  $opensips_pack_version =	$zonkey::params::opensips_pack_version,

  $ast_cdrs_table =	        $zonkey::params::ast_cdrs_table,
  $ast_port =                   $zonkey::params::ast_port,
  $ast_directmedia =            $zonkey::params::ast_directmedia,
  $ast_notification_email =     $zonkey::params::ast_notification_email,
  $ast_rtp_port =               $zonkey::params::ast_rtp_port,
  $ast_skinny =                 $zonkey::params::ast_skinny,
  $ast_resources =		$zonkey::params::ast_resources,
  $default_lang =           	$zonkey::params::default_lang,
  $ami_user =			$zonkey::params::ami_user,
  $ami_pass = 			$zonkey::params::ami_pass,
  $ami_permit =			$zonkey::params::ami_permit,
  $ami_host =			$zonkey::params::ami_host,
  $ami_sccp_host =		$zonkey::params::ami_sccp_host,
  $ami_queue_host =		$zonkey::params::ami_queue_host,

) inherits zonkey::params {

  validate_string($db_name)
  validate_string($db_drop)
  validate_string($db_root_pass)
  validate_string($db_user_user)
  validate_string($db_user_pass)
  validate_array($db_ips)
  validate_string($db_host)
  validate_string($db_port)
  validate_string($db_from_network)
  validate_numeric($db_server_id, 4, 1)
  validate_string($gui_base_domain)
  validate_string($gui_root_user)
  validate_string($gui_root_pass)
  validate_string($gui_passenger_version)
  validate_string($gui_ruby_version)
  validate_string($gui_gems_path)
  validate_string($gui_ip)
  validate_bool($gui_deploy_rake)
  validate_string($opensips_listen_interface)
  validate_numeric($opensips_port,65535,1)
  validate_array($opensips_ip)
  validate_string($opensips_mgm_ip)
  validate_string($opensips_skinny_ip)
  validate_string($opensips_floating_ip)
  validate_string($opensips_pack_version)
  validate_string($legacy_server)
  validate_string($ast_cdrs_table)
  validate_numeric($ast_port,65535,1)
  validate_string($ast_directmedia)
  validate_string($ast_notification_email)
  validate_array($ast_rtp_port)
  validate_bool($ast_skinny)
  validate_string($default_lang)


  $ip = $::ipaddress
  $db_ips_0 = $db_ips[0]
  $db_ips_1 = $db_ips[1]
  $rtp_port_start = $ast_rtp_port[0]
  $rtp_port_end = $ast_rtp_port[1]
  $fqdn = $::fqdn

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'mariadb-server','mariadb','tftp-server','mariadb-devel','mysql++-devel','libxml2-devel','libicu-devel','httpd','httpd-devel','libcurl-devel','libapreq2-devel','ImageMagick-devel','apr-devel','apr-util-devel','sox','mod_ssl','gmp-devel','modulis-zonkey','sqlite-devel','xinetd','perl-ExtUtils-Embed','perl-RPC-XML','perl-XMLRPC-Lite','perl-libapreq2','perl-JSON','perl-Redis','perl-Apache-Session-Redis','redis','hiredis','perl','perl-SOAP-Lite','bison','lynx','flex','modulis-opensips','libmicrohttpd-devel','mysql-connector-odbc','modulis-dahdi-complete','modulis-cert-asterisk' ]  
      $mysql_package = mariadb-server
      $mysql_service = mariadb
      $mysql_client = mariadb
      $mysql_conf = "/etc/my.cnf"
      $mysql_log = "/var/log/mariadb/mariadb.log"
      $mysql_pid = "/var/run/mariadb/mariadb.pid"
      $mysql_slow_log = "/var/log/mariadb/mariadb-slow.log"
      $mysql_socket = "/var/lib/mysql/mysql.sock"
      $ruby_update_path = "/usr/bin/update_rubygems"
      $apache_user = "apache"
      $apache_log = "/var/log/httpd"
      $apache_service = "httpd"
      $gems_path = "/var/lib64/gems"
      $redis_service = "redis"

      file { ['/var/log/httpd','/var/log/httpd/zonkey','/etc/zonkey/bin' ]:
        ensure => 'directory',
        owner => 'apache', group => 'apache',
        mode => 0750,
      }
      file { ['/etc/zonkey' ]:
        ensure => 'directory',
        owner => 'root', group => 'root',
        mode => 0755,
      }
    }
    /^(Debian|Ubuntu)$/: { 
      $package = [ 'mysql-server','tftpd-hpa','libmysqld-dev','libmysql++-dev','libxml2-dev','libicu-dev','apache2','apache2-dev','libcurl4-gnutls-dev','libsqlite3-dev','libssl-dev','graphicsmagick-libmagick-dev-compat','libmagickwand-dev','ruby-all-dev','libapr1-dev','libaprutil1-dev','libapreq2-3','libapreq2-dev','xinetd','sox','lame','openssl','modulis-zonkey','perl-modules','librpc-xml-perl','libxmlrpc-lite-perl','libjson-perl','libredis-perl','libapache-session-perl','redis-server','libhiredis0.10','perl','libsoap-lite-perl','bison','lynx','flex','mysql-client','libmicrohttpd-dev','modulis-opensips-conf','modulis-cert-asterisk','modulis-dahdi','libwww-perl','libparallel-forkmanager-perl','libanyevent-perl','libdbd-mysql-perl' ] 
      $package_opensips = [ 'opensips','opensips-b2bua-module','opensips-carrierroute-module','opensips-console','opensips-cpl-module','opensips-dbg','opensips-dbhttp-module','opensips-dialplan-module','opensips-geoip-module','opensips-http-modules','opensips-identity-module','opensips-jabber-module','opensips-json-module','opensips-ldap-modules','opensips-lua-module','opensips-memcached-module','opensips-mysql-module','opensips-perl-modules','opensips-postgres-module','opensips-presence-modules','opensips-rabbitmq-module','opensips-radius-modules','opensips-redis-module','opensips-regex-module','opensips-restclient-module','opensips-snmpstats-module','opensips-unixodbc-module','opensips-xmlrpcng-module','opensips-xmlrpc-module','opensips-xmpp-module' ] 
      $mysql_package = mysql-server
      $mysql_service = mysql
      $mysql_client = mariadb-client
      $mysql_conf = "/etc/mysql/my.cnf"
      $mysql_log = "/var/log/mysql/mysql.log"
      $mysql_pid = "/var/run/mysqld/mysql.pid"
      $mysql_slow_log = "/var/log/mysql/mysql-slow.log"
      $mysql_socket = "/var/run/mysqld/mysqld.sock"
      $apache_user = "www-data"
      $apache_log = "/var/log/apache2"
      $apache_service = "apache2"
      $redis_service = "redis-server"

      file { ['/var/log/apache2','/var/log/apache2/zonkey','/etc/zonkey/bin' ]:
        ensure => 'directory',
        owner => 'www-data', group => 'www-data',
        mode => 0750,
      }
      file { ['/etc/zonkey' ]:
        ensure => 'directory',
        owner => 'root', group => 'root',
        mode => 0755,
      }
    }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  package { $package_opensips:
    ensure => "$opensips_pack_version",
    require => Class['zonkey::package'],
  }

## DB installation
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
  }
  file { $mysql_conf:
    owner => "root", group => "mysql",
    mode => 0640,
    content => template("zonkey/my.cnf.erb"),
    require => Package[$mysql_package],
    notify => Service[$mysql_service],
  }
  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$db_root_pass status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $db_root_pass  && /etc/init.d/mysql restart",
    require => Service[$mysql_service],
  } ->
  exec { "db-drop":
    onlyif => "/usr/bin/test -d /var/lib/mysql/$db_drop",
    command => "/usr/bin/mysql -uroot -p$db_root_pass -e \"drop database $db_drop; delete from mysql.user where user='' or password='' or host='';\"",
    require => Service[$mysql_service],
  } ->
  exec { "create-db":
    unless => "/usr/bin/test -d /var/lib/mysql/$db_name",
    command => "/usr/bin/mysql -uroot -p$db_root_pass -e \"create database $db_name; grant all privileges on $db_name.* to '$db_user_user'@'$db_from_network' identified by '$db_user_pass'; grant all privileges on $db_name.* to '$db_user_user'@'127.0.0.1' identified by '$db_user_pass'; grant super on *.* to '$db_user_user'@'$db_from_network' identified by '$db_user_pass'; grant all privileges on *.* to 'root'@'$db_from_network' identified by '$db_root_pass' with grant option; grant super on *.* to 'root'@'$db_from_network' identified by '$db_root_pass'; flush privileges\"",
    require => Service[$mysql_service],
  }
  if $db_replication == true {
    if $db_ips[0] == $::ipaddress {
      exec { "set-replication-to-ip0":
        creates => "/var/lib/mysql/.replication.done.do.not.delete.for.puppet",
        command => "/usr/bin/mysql -uroot -p$db_root_pass -h 127.0.0.1 -e \"GRANT ALL ON *.* TO 'root'@'$db_ips_1' IDENTIFIED BY '$db_root_pass'; GRANT REPLICATION SLAVE ON *.* TO 'replica'@'$db_ips_1' IDENTIFIED BY '$db_replication_pass'; FLUSH PRIVILEGES;\" && touch /var/lib/mysql/.replication.done.do.not.delete.for.puppet",
        require => Service[$mysql_service],
      }
    }
    elsif $db_ips[1] == $::ipaddress {
      exec { "set-replication-to-ip1":
        creates => "/var/lib/mysql/.replication.done.do.not.delete.for.puppet",
        command => "/usr/bin/mysql -uroot -p$db_root_pass -h 127.0.0.1 -e \"GRANT ALL ON *.* TO 'root'@'$db_ips_0' IDENTIFIED BY '$db_root_pass'; FLUSH PRIVILEGES; change master to master_host='$db_ips_0',master_user='replica',master_password='$db_replication_pass',master_log_file='$db_master_log_file',master_log_pos=$db_master_log_pos;start slave;\" && touch /var/lib/mysql/.replication.done.do.not.delete.for.puppet",
        require => Service[$mysql_service],
      }
    }
  }
  cron { "db_backup_wo_voicemails":
    ensure => "present",
    user => 'root',
    command => "/usr/bin/nice -n19 /usr/bin/mysqldump -h $MYHOST -p$MYPASS -u$MYUSER --single-transaction --quick --ignore-table=zonkey.voicemail_files zonkey | /bin/gzip -c > /data/mysqlbackup/zonkey-dump-novm-$(date +%u).sql.gz",
    hour => 0,
    minute => 2,
    environment => ["SHELL=/bin/bash","PATH=/sbin:/bin:/usr/sbin:/usr/bin","MYUSER=root","MYPASS=$db_root_pass","MYHOST=localhost"],
  }
  cron { "db_backup_with_voicemails":
    ensure => "present",
    user => 'root',
    command => "/usr/bin/nice -n19 /usr/bin/mysqldump -h $MYHOST -p$MYPASS -u$MYUSER --single-transaction --quick zonkey | /bin/gzip -c > /data/mysqlbackup/zonkey-dump-vm-$(date +%u).sql.gz",
    hour => 0,
    minute => 5,
  }
  file { ["/data","/data/mysqlbackup/"]:
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '0700',
  }
  service { $mysql_service:
    ensure => 'running',
    enable => true,
  }

## GUI installation
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
    require => [ Package['modulis-zonkey'], Exec["create-db"] ],
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
    exec { "populate_database":
      creates => '/root/.populate.mysql.do.not.delete.for.puppet',
      path => "/usr/bin/",
      command => "mysql -u $db_user_user -p$db_user_pass -h $db_host -e \"insert into zonkey.load_balancer (group_id, dst_uri, resources, probe_mode, description) VALUES (1, 'sip:$::ipaddress:$ast_port', '$ast_resources', 1, '$::hostname'); insert into zonkey.routing_gateways set realm_id = 0, type=10, address = '$::ipaddress', description = '$::hostname', created_at = now(), updated_at = now(); update zonkey.routing_gateways set gwid=id where address='$::ipaddress'\" && touch /root/.populate.mysql.do.not.delete.for.puppet",
      require => [ File['/root/.my.cnf'], File['/var/www/zonkey/rakeDeployConfig.expect'] ],
    }
  }
  else {
    case $::operatingsystem {
      'CentOS', 'RedHat': {
        exec { 'deploy-zonkey':
          cwd => '/var/www/zonkey',
          creates => '/root/.zonkey.deployed.do.not.delete.for.puppet',
          command => "/usr/bin/yum install -y expect git patch gcc gcc-c++ && /usr/bin/bundle install --without development test && bundle exec rake assets:precompile && /usr/bin/yum remove gcc gcc-c++ -y && chown -R apache. /var/www && touch /root/.zonkey.deployed.do.not.delete.for.puppet",
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

##  OpenSIPS installation
  file { '/etc/zonkey/opensips/modules_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/modules_params.cfg.erb'),
    require => Package['modulis-opensips-conf'],
  }
  file { '/etc/zonkey/opensips/global_params.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/global_params.cfg.erb'),
    require => Package['modulis-opensips-conf'],
  }
  file { '/etc/zonkey/opensips/shared_vars.cfg':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/shared_vars.cfg.erb'),
    require => Package['modulis-opensips-conf'],
  }
  file { '/etc/opensips/opensipsctlrc':
    owner => 'root', group => 'opensips',
    mode => 0640,
    content => template('zonkey/opensipsctlrc.erb'),
    require => Package['opensips'],
  }
  service { $redis_service:
    ensure => 'running',
    enable => true,
    require => Package[$redis_service],
  }
  service { 'opensips':
    ensure => 'running',
    enable => true,
    require => Service[$redis_service],
  }
  if $opensips_floating_ip != "127.0.0.1" {
    exec { 'sysctl.non.local.bind':
      creates => '/root/.non.local.bind.do.not.delete.for.puppet',
      path => '/bin',
      command => 'echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf && touch "/root/.non.local.bind.do.not.delete.for.puppet"',
      notify => Service['opensips'],
    }
  }
  service { "rsyslog":
    ensure => "running",
    enable => "true",
  }
  exec { "add_opensips_to_rsyslog":
    unless => "/bin/grep 'local5.* -/var/log/opensips/opensips.log' /etc/rsyslog.conf",
    command => "/bin/echo 'local5.* -/var/log/opensips/opensips.log' >> /etc/rsyslog.conf",
    notify => Service["rsyslog"],
  }
  exec { "no_opensips_to_messages":
    unless => "/bin/grep 'local5.none -/var/log/messages' /etc/rsyslog.conf",
    command => "/bin/echo 'local5.none -/var/log/messages' >> /etc/rsyslog.conf",
    notify => Service['rsyslog'],
  }
  file { 'opensips.logrot':
    ensure => 'present',
    path => '/etc/logrotate.d/opensips',
    source => 'puppet:///modules/zonkey/opensips.logrot',
    owner => 'root',
    group => 'root',
    mode => 0644,
  }   

## Asterisk installation
  file { '/etc/zonkey/asterisk/cdr_mysql.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/cdr_mysql.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/extensions_global.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/extensions_global.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/sip_general_custom.conf':
    owner => 'root', group => 'asterisk',
    mode => 0750,
    content => template('zonkey/sip_general_custom.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/sip_static.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/sip_static.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/zonkey.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/zonkey.conf.ast.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/odbc.ini':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/odbc.ini.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/rtp_static.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/rtp_static.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  case $::operatingsystem {
    'CentOS', 'RedHat': {
      file { '/usr/lib/systemd/system/asterisk.service':
        owner => 'root', group => 'root',
        mode => 0640,
        source => 'puppet:///modules/zonkey/asterisk.service',
        require => Package['modulis-cert-asterisk'],
      }
      service { 'asterisk':
        ensure => 'running',
        enable => true,
        require => File['/usr/lib/systemd/system/asterisk.service'],
      }
    }
    'Debian','Ubuntu': {
      service { 'asterisk':
        ensure => 'running',
        enable => true,
        require => Package['modulis-cert-asterisk'],
      }
    }
  }
  file { '/etc/zonkey/asterisk/asterisk.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/asterisk.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/asterisk/voicemail_general.cfg':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/voicemail_general.cfg.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  file { '/etc/zonkey/bin/externnotify.sh':
    owner => 'root', group => 'asterisk',
    mode => 0750,
    content => template('zonkey/externnotify.sh.erb'),
    require => Package['modulis-cert-asterisk'],
  }
  file { '/etc/asterisk/manager.conf':
    ensure => 'present',
    owner => "root", group => "asterisk",
    mode => 0640,
    source => 'puppet:///modules/zonkey/manager.conf',
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  } ->
  file { '/etc/zonkey/asterisk/manager_custom.conf':
    owner => 'root', group => 'asterisk',
    mode => 0640,
    content => template('zonkey/manager_custom.conf.erb'),
    require => Package['modulis-cert-asterisk'],
    notify => Service['asterisk'],
  }
  exec { "cp_odbcinst":
    unless => "/bin/ls /etc/odbcinst.ini",
    command => "/bin/cp /usr/share/libmyodbc/odbcinst.ini /etc/",
    require => Package['libmyodbc'],
  }
  file { "/etc/logrotate.d/asterisk":
    owner => "root", group => "root",
    mode => 0640,
    source => 'puppet:///modules/zonkey/asterisk.logrot',
  }
}
