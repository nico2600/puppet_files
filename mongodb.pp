# DWTFYW license
# for educational purpose
#

include apt

class mongo {

   apt_key { 'mongodb':
      ensure => 'present',
      id   => '7F0CEB10',
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
      require                 => Package['mongodb-org'],
      source                  => "puppet:///files/mongo/mongodb.conf",
      mode                    => 644,
      owner                   => root,
      group                   => root,
      notify                  => Service["mongod"],
   }

   # Make sure that the nginx service is running
   service { 'mongod':
      ensure    => "running",
      #   enable    => true, XXX: some bug, lead: package name different from service one ?
      subscribe => File['mongodb.conf'],
   }

   # install shell, tools and server
   # user mongodb will be created too
   package { 'mongodb-org':
      ensure => 'installed',
   }

   # TODO: check user mongodb
}

