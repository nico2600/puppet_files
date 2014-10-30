# DWTFYW license
# for educational purpose
#

include apt

class mongo {

   apt_key { 'mongodb':
      ensure => 'present',
      id   => '7F0CEB10',
   }
   exec { "mongo-apt-update":
      path        => "/bin:/usr/bin",
      command     => "apt-get update",
      unless      => "ls /usr/bin | grep mongo",
   }

   apt::source { 'mongodb':
      # uncomment line below to use upstart script instead of init
      # location => 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart',
      # we're still using init 
      # TODO: systemd ?
      location => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
      release         => 'dist',
      repos           => '10gen',
      key             => '4BD6EC30',
      include_src     => false,
      include_deb     => true
   }

   # RW for user mongodb
   file { ['/var/run/mongodb/','/var/lib/mongo']:
      ensure => 'directory',

   }

   file { 'mongodb.conf':
      path                    => '/etc/mongodb.conf',
      ensure                  => 'present',
      source                  => "puppet:///files/mongo/mongodb.conf",
      # conf in RO for user mongodb
      mode                    => 644,
      owner                   => root,
      group                   => root,
      notify                  => Service["mongod"],
      require                 => Package['mongodb-org'],
   }

   # Make sure that the nginx service is running
   service { 'mongod':
      ensure    => "running",
      enable    => true,
      subscribe => File['mongodb.conf'],
   }

   # install shell, tools and server
   # user mongodb will be created too
   # TODO: mongo-org is a metapackage, better to focus on a more specific one
   # TODO: pin the version
   package { 'mongodb-org':
      ensure  => 'installed',
      require => Exec["mongo-apt-update"],
   }

   user { "mongodb":
      ensure  => present,
      require => Package['mongodb-org'],
   }

}

