class zonkey::params {
  $rvm_version = "stable"
  $keyserver = "hkp://keys.gnupg.net"  
  $recvkeys = "409B6B1796C275462A1703113804BB82D39DC0E3"
  $db_name = "zonkey"						## Name to give to the db that will be created
  $db_drop = "test"						## Will drop this database, if it exists
  $db_root_pass = "knn4Hwu7kgdS6k"				## MySQL root password
  $db_user_user = "zonkey"					## MySQL user that will be created
  $db_user_pass = "hTAz2UPwDgbwjyu"				## MySQL password for the user we will create
  $db_ips = ['127.0.0.1']					## Array of MySQL ip, used for replication
  $db_host = '127.0.0.1'					## IP used to access to MySQL server
  $db_port = '3306'						## Port used to access to MySQL server
  $db_from_network = "199.182.132.%"				## Access to MySQL will be allowed from this network
  $db_server_id = 1						## Used for replication.  1 for master and standalone, 2 for slave.  Also used for auto_increment
  $db_replication = false					## Enable replication
  $db_master_log_file = "mariadb-bin.000001"			## File used for db replication
  $db_master_log_pos = 106					## Position used for db replication
  $gui_base_domain = "test.modulis.ca"				## Base domain that will be used for root login
  $gui_root_user = "root"					## Full admin user that will be created with the base domain (root@test.modulis.ca)
  $gui_root_pass = "uf8175WpiV6rLDG"				## Password for the root user
  $gui_passenger_version = "passenger-5.0.23"			## Passenger version used in Apache
  $gui_ruby_version = "2.1.0" 					## Ruby version used in Apache
  $gui_deploy_rake = 1	 					## Used to check if we deploy rake - Should be set to 1 on master GUI and 0 on slave (need db replication to set to 0)
  $gui_ip = "127.0.0.1"						## MGM IP that Asterisk will use to send notification email : /etc/zonkey/asterisk/extensions_global.conf and ip used in /etc/zonkey/opensips/shared_vars.cfg
  $opensips_ip = ['127.0.0.1']					## Ip of Opensips, used in /etc/zonkey/opensips/shared_vars.cfg & /etc/zonkey/opensips/modules_params.cfg
  $opensips_floating_ip = "127.0.0.1"				## Opensips IP that asterisk will use as outbound proxy : /etc/zonkey/asterisk/sip_general_custom, /etc/zonkey/asterisk/sip_static.conf
  $opensips_base_domain = "test.modulis.ca"			## Base domain used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_listen_interface = "ens160"				## Default interface on which Opensips will listen, used in /etc/zonkey/opensips/global_params.cfg
  $opensips_port = 8060						## Default port on which Opensips will listen, used in /etc/zonkey/opensips/global_params.cfg
  $opensips_skinny_ip = "127.0.0.1"				## Asterisk Skinny ip used in /etc/zonkey/opensips/shared_vars.cfg
  $legacy_server = ""						## Used for coexistance of 2 server when we do migration.  All call to non-local ext, will be send to this ip
  $ast_resources = "pbx=100;vm=100;ivr=100;queue=100"		## Asterisk resources, used for creating entries in load_balancer table
  $ast_cdrs_table = "cdrs"					## Database table that asterisk will use to put CDR : /etc/zonkey/asterisk/cdr_mysql.conf
  $ast_db_host = "127.0.0.1"					## Used to tell Asterisk which DB to use
  $ast_port = 5060						## Port that asterisk will try to bind to
  $default_lang = "en"						## Default language of the system : /etc/zonkey/asterisk/sip_static.conf
  $ast_directmedia = false					## Do we use directmedia : /etc/zonkey/asterisk/sip_general_custom.conf
  $ast_notification_email = "voipadmin@modulis.ca"		## Notification email, where to send : /etc/zonkey/asterisk/extensions_global.conf, /etc/zonkey/asterisk/zonkey.conf
  $ast_rtp_port = ['10000','20000']				## Range of RTP port : /etc/zonkey/asterisk/rtp_static.conf
  $ast_skinny = false						## Enable skinny config
  $sccp_realm = "campus.voip.etsmtl.ca"				## Realm used for SCCP, in /etc/zonkey/asterisk/extensions_globals.conf
  $ami_user = "zonkey"						## AMI user used by Zonkey setup
  $ami_pass = "uhwn8Fet2j?o"					## AMI password used by Zonkey setup
  $ami_permit = "10.0.0.0/255.0.0.0"				## AMI permit network
  $ami_host = ['127.0.0.1']					## AMI address for media host (used in GUI, in asterisk-ajam.yml)
  $ami_sccp_host = ['127.0.0.1']				## AMI address for sccp host (used in GUI, in asterisk-ajam.yml)
  $ami_queue_host = ['127.0.0.1']				## AMI address for queue host (used in GUI, in asterisk-ajam.yml)
}
