class zonkey::params {
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
  $gui_db_user = $db_user_user					## User used in /var/www/zonkey/config/database.yml 
  $gui_db_pass = $db_user_pass					## Password used in /var/www/zonkey/config/database.yml
  $gui_db_host = "localhost"					## Host used in /var/www/zonkey/config/database.yml
  $gui_db_port = 3306						## Port used in /var/www/zonkey/config/database.yml
  $gui_db_name = "zonkey"					## DB name used in /var/www/zonkey/config/database.yml
  $gui_base_domain = "test.modulis.ca"				## Base domain that will be used for root login
  $gui_root_user = "root"					## Full admin user that will be created with the base domain (root@test.modulis.ca)
  $gui_root_pass = "uf8175WpiV6rLDG"				## Password for the root user
  $opensips_db_user = $db_user_user                             ## User used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_db_pass = $db_user_pass                             ## Password used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_db_host = $gui_db_host                              ## Host used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_db_name = $gui_db_name                              ## Host used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_ip = ['127.0.0.1']					## Ip of Opensips, used in /etc/zonkey/opensips/shared_vars.cfg & /etc/zonkey/opensips/modules_params.cfg
  $opensips_base_domain = "test.modulis.ca"			## Base domain used in /etc/zonkey/opensips/modules_params.cfg
  $opensips_listen_interface = "ens160"				## Default interface on which Opensips will listen, used in /etc/zonkey/opensips/global_params.cfg
  $opensips_port = 5060						## Default port on which Opensips will listen, used in /etc/zonkey/opensips/global_params.cfg
  $opensips_mgm_ip = "127.0.0.1"				## MGM ip used in /etc/zonkey/opensips/shared_vars.cfg
  $opensips_skinny_ip = "127.0.0.1"				## Asterisk Skinny ip used in /etc/zonkey/opensips/shared_vars.cfg
  $ast_ip = "127.0.0.1"						## Asterisk ip used in 
  $ast_db_host = "127.0.0.1"					## IP of SQL server that asterisk will use : /etc/zonkey/asterisk/cdr_mysql.conf,/etc/odbc.ini,/etc/zonkey/asterisk/zonkey.conf
  $ast_db_name = $db_name					## Database name that asterisk will use : /etc/zonkey/asterisk/cdr_mysql.conf,/etc/odbc.ini,/etc/zonkey/asterisk/zonkey.conf
  $ast_db_user = $db_user_user					## Database user that asterisk will use : /etc/zonkey/asterisk/cdr_mysql.conf,/etc/odbc.ini,/etc/zonkey/asterisk/zonkey.conf 
  $ast_db_pass = $db_user_pass					## Database pass that asterisk will use : /etc/zonkey/asterisk/cdr_mysql.conf,/etc/odbc.ini,/etc/zonkey/asterisk/zonkey.conf
  $ast_db_cdrs_table = "cdrs"					## Database table that asterisk will use to put CDR : /etc/zonkey/asterisk/cdr_mysql.conf
  $ast_port = 8060						## Port that asterisk will try to bind to
  $ast_opensips_ip = "127.0.0.1"				## Opensips IP that asterisk will use as outbound proxy : /etc/zonkey/asterisk/sip_general_custom, /etc/zonkey/asterisk/sip_static.conf
  $ast_opensips_port = 5060					## Opensips port that asterisk will use in the outbound proxy: /etc/zonkey/asterisk/sip_general_custom
  $ast_mgm01_ip = "127.0.0.1"					## MGM IP that Asterisk will use to send notification email : /etc/zonkey/asterisk/extensions_global.conf
  $ast_default_lang = "en"					## Default language of the system : /etc/zonkey/asterisk/sip_static.conf
  $ast_directmedia = false					## Do we use directmedia : /etc/zonkey/asterisk/sip_general_custom.conf
  $ast_notification_email = "voipadmin@modulis.ca"		## Notification email, where to send : /etc/zonkey/asterisk/extensions_global.conf, /etc/zonkey/asterisk/zonkey.conf
  $ast_rtp_port = ['10000','20000']				## Range of RTP port : /etc/zonkey/asterisk/rtp_static.conf
  $ast_skinny = false						## Enable skinny config
}
