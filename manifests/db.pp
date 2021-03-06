class zonkey::db (
  $db_name		= $zonkey::params::db_name,
  $db_drop		= $zonkey::params::db_drop,
  $db_root_pass		= $zonkey::params::db_root_pass,
  $db_user_user		= $zonkey::params::db_user_user,
  $db_user_pass		= $zonkey::params::db_user_pass,
  $db_ips		= $zonkey::params::db_ips,
  $db_from_network	= $zonkey::params::db_from_network,
  $db_server_id		= $zonkey::params::db_server_id,
  $db_replication	= $zonkey::params::db_replication,  
  $db_replication_pass  = $zonkey::params::db_replication_pass,
  $db_master_log_file 	= $zonkey::params::db_master_log_file,
  $db_master_log_pos	= $zonkey::params::db_master_log_pos,

) inherits zonkey::params {
  validate_string($db_name)
  validate_string($db_drop)
  validate_string($db_root_pass)
  validate_string($db_user_user)
  validate_string($db_user_pass)
  validate_array($db_ips)
  validate_string($db_from_network)
  validate_numeric($db_server_id, 4, 1)
  validate_bool($db_replication)

  $db_ips_0 = $db_ips[0]
  $db_ips_1 = $db_ips[1]

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'mariadb-server','mariadb' ] 
      $mysql_service = mariadb
      $mysql_client = mariadb
      $mysql_conf = "/etc/my.cnf"
      $mysql_log = "/var/log/mariadb/mariadb.log"
      $mysql_pid = "/var/run/mariadb/mariadb.pid"
      $mysql_slow_log = "/var/log/mariadb/mariadb-slow.log"
      $mysql_socket = "/var/lib/mysql/mysql.sock"
    }
    /^(Debian|Ubuntu)$/: { 
      $package = [ 'mariadb-server','mariadb-client' ] 
      $mysql_service = mysql
      $mysql_client = mariadb-client
      $mysql_conf = "/etc/mysql/my.cnf"
      $mysql_log = "/var/log/mysql/mysql.log"
      $mysql_pid = "/var/run/mysqld/mysql.pid"
      $mysql_slow_log = "/var/log/mysql/mysql-slow.log"
      $mysql_socket = "/var/run/mysqld/mysqld.sock"
    }
  }
  package { $package:
    ensure => 'latest',
    require => Class['zonkey::package'],
  }
  file { "/root/.my.cnf":
    owner => "root", group => "root",
    mode => 0600,
    content => template("zonkey/.my.cnf.erb"),
  }
  file { $mysql_conf:
    owner => "root", group => "mysql",
    mode => 0640,
    content => template("zonkey/my.cnf.erb"),
    require => Package["mariadb-server"],
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
}
