class zonkey::params {
  $redundancy = false
  $asterisk_port = 5060
  $opensips_port = 8060
  $rvm_version = "stable"
  $keyserver = "hkp://keys.gnupg.net"  
  $recvkeys = "409B6B1796C275462A1703113804BB82D39DC0E3"
  $db_name = "zonkey"						## Name to give to the db that will be created
  $db_drop = "test"						## Will drop this database, if it exists
  $db_root_pass = "knn4Hwu7kgdS6k"				## MySQL root password
  $db_user_user = "zonkey"					## MySQL user that will be created
  $db_user_pass = "hTAz2UPwDgbwjyu"				## MySQL password for the user we will create
  $db_ip = ['127.0.0.1']					## Array of MySQL ip
  $db_from_network = "199.182.132.%"				## Access to MySQL will be allowed from this network
  $db_server_id = 1						## Used for replication.  1 for master and standalone, 2 for slave.  Also used for auto_increment
  $db_replication = false					## Enable replication

}
