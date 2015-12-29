class zonkey::package (
  $keyserver		= $zonkey::params::keyserver,
  $recvkeys		= $zonkey::params::recvkeys,

) inherits zonkey::params {

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      $package = [ 'policycoreutils-python','man-db','wget','nano','rsync','openvpn','iptables-services','fail2ban','mtr','atop','iotop','iftop','iptraf-ng','ngrep','sysstat','dstat','logwatch','audit','whowatch','tripwire','fail2ban-all','ruby' ]
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
    /^(Debian|Ubuntu)$/:{ $package = ['manpages','wget','curl','nano','openvpn' ]  }
  }

  exec { 'setup rvm':
    cwd     => "/root/",
    command => "/usr/bin/gpg2 --keyserver $keyserver --recv-keys $recvkeys && /usr/bin/curl -sSL https://get.rvm.io | /bin/bash -s stable && /usr/bin/echo source /usr/local/rvm/scripts/rvm >> /root/.bashrc && source /root/.bashrc && /usr/bin/echo gem: --no-ri --no-rdoc >> /root/.gemrc",
    unless  => "/usr/bin/test -f /usr/local/rvm",
    timeout => 1200,
  }
}
