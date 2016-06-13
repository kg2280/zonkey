class zonkey::package (
  $keyserver		= $zonkey::params::keyserver,
  $recvkeys		= $zonkey::params::recvkeys,

) inherits zonkey::params {

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'policycoreutils-python','man-db','wget','nano','rsync','openvpn','iptables-services','fail2ban','mtr','atop','iotop','iftop','iptraf-ng','ngrep','sysstat','dstat','logwatch','audit','whowatch','tripwire','fail2ban-all','ruby','libiodbc','screen' ]
      file { 'modulis.repo':
        ensure => 'present',
        path => '/etc/yum.repos.d/modulis.repo',
        source => 'puppet:///modules/zonkey/modulis.repo',
        owner => 'root',
        group => 'root',
        mode => 0644,
      } ->
      package { $package:
        ensure => 'latest',
        require => Class['epel'],
      }

    }
    /^(Debian|Ubuntu)$/: { 
      $package = ['manpages','wget','curl','nano','openvpn','fail2ban','policycoreutils','mtr','atop','iotop','iftop','iptraf-ng','ngrep','sysstat','dstat','logwatch','whowatch','tripwire','ruby-full','screen','libodbc1','libmyodbc','gnupg2' ]
      file { 'modulis.list':
        ensure => 'present',
        path => '/etc/apt/sources.list.d/modulis.list',
        source => 'puppet:///modules/zonkey/modulis.list',
        owner => 'root',
        group => 'root',
        mode => 0644,
      } ->
      file { 'sources.list':
        ensure => 'present',
        path => '/etc/apt/sources.list',
        source => 'puppet:///modules/zonkey/sources.list',
        owner => 'root',
        group => 'root',
        mode => 0644,
      } ->
      exec { 'opensips_pgp_key':
        creates => "/root/.opensips_pgp_key.do.not.remove.for.puppet",
	command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 81CE21E7049AD65B && /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5F2FBB7C && touch /root/.opensips_pgp_key.do.not.remove.for.puppet",
      } ->
      exec { 'modulis_pgp_key':
        creates => "/root/.modulis_pgp_key.do.not.remove.for.puppet",
	command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A7E87401 && touch /root/.modulis_pgp_key.do.not.remove.for.puppet",
      } ->
      exec { 'apt-update':
        command => "/usr/bin/apt-get update",
      } ->
      package { $package:
        ensure => 'latest',
      }
    }
  } ->

  case $::operatingsystem {
    'Centos', 'RedHat': {
      exec { 'setup rvm':
        cwd     => "/root/",
        unless  => "/usr/bin/test -d /usr/local/rvm",
        command => "/usr/bin/gpg2 --keyserver $keyserver --recv-keys $recvkeys && /usr/bin/curl -sSL https://get.rvm.io | /bin/bash -s stable && /usr/bin/echo source /usr/local/rvm/scripts/rvm >> /root/.bashrc && source /root/.bashrc && /usr/bin/echo gem: --no-ri --no-rdoc >> /root/.gemrc",
        timeout => 1200,
      }
    }
    'Debian', 'Ubuntu': {
      exec { 'setup rvm':
        cwd     => "/root/",
        unless  => "/usr/bin/test -d /usr/local/rvm",
        command => "/usr/bin/gpg2 --keyserver $keyserver --recv-keys $recvkeys && /usr/bin/curl -sSL https://get.rvm.io | /bin/bash -s stable && /bin/echo source /usr/local/rvm/scripts/rvm >> /root/.bashrc && source /root/.bashrc && /bin/echo gem: --no-ri --no-rdoc >> /root/.gemrc",
        timeout => 1200,
      }
    }
  }
  cron { "puppet-agent":
          ensure  => present,
          command => "/usr/sbin/puppet --onetime --no-daemonize --splay --logdest syslog > /dev/null 2>&1",
          user    => 'root',
          minute  => [ 30 ],
  }
}
