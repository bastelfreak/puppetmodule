#
# This module is used to setup the puppetlabs repos
# that can be used to install puppet. we use ini_setting instead of
# yumrepo because of a bug: https://tickets.puppetlabs.com/browse/PUP-2782
#
# Class: puppet::repo::puppetlabs
#
# Parameters:
# - mirror - base URL to your mirror
# - priority - set priority for a yum repo
#
# Actions:
# - configures a apt our yum repo 
#
# Requires:
# - inifile
#
# Sample Usage:
#   class {'puppet::repo::puppetlabs':
#     mirror => 'apt.puppetlabs.com',
#   }
#
# written by Stephen Johnson
# extended by Tim 'bastelfreak' Meusel

class puppet::repo::puppetlabs(
  $mirror = $puppet::params::mirror,
  $priority = 1,
){

  if($::osfamily == 'Debian') {
    Apt::Source {
      location    => $mirror,
      key         => '4BD6EC30',
      key_content => template('puppet/pgp.key'),
    }
    apt::source { 'puppetlabs':      repos => 'main' }
    apt::source { 'puppetlabs-deps': repos => 'dependencies' }
  } elsif $::osfamily == 'Redhat' {
    if $::operatingsystem == 'Fedora' {
      $ostype='fedora'
      $prefix='f'
    } else {
      $ostype='el'
      $prefix=''
    }
    $gpg_destination = '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs'
    include wget
    wget::fetch { "${mirror}/RPM-GPG-KEY-puppetlabs":
      destination => $gpg_destination,
      timeout     => 0,
      verbose     => false,
    }
    Ini_setting {
      ensure  => present,
      path    => '/etc/yum.repos.d/puppetlabs.repo',
    }
    ini_setting {'puppetlabs-products-name':
      section => 'puppetlabs-products',
      value   => "Puppet Labs Products ${ostype} ${::operatingsystemmajrelease} - \$basearch",
      setting => 'name',
    }
    ini_setting {'puppetlabs-products-gpgkey':
      section => 'puppetlabs-products',
      value   => "file://${gpg_destination}",
      setting => 'gpgkey',
    }
    ini_setting {'puppetlabs-products-enabled':
      section => 'puppetlabs-products',
      value   => '1',
      setting => 'enabled',
    }
    ini_setting {'puppetlabs-products-baseurl':
      section => 'puppetlabs-products',
      value   => "${mirror}/packages/yum/${ostype}/${::operatingsystemmajrelease}/products/\$basearch",
      setting => 'baseurl',
    }
    ini_setting {'puppetlabs-products-priority':
      section => 'puppetlabs-products',
      value   => $priority,
      setting => 'priority',
    }
    ini_setting {'puppetlabs-products-gpgcheck':
      section => 'puppetlabs-products',
      value   => '1',
      setting => 'gpgcheck',
    }
    ini_setting {'puppetlabs-dependencies-name':
      section => 'puppetlabs-deps',
      value   => "Puppet Labs Dependencies ${ostype} ${::operatingsystemmajrelease} - \$basearch",
      setting => 'name',
    }
    ini_setting {'puppetlabs-dependencies-gpgkey':
      section => 'puppetlabs-deps',
      value   => "file://${gpg_destination}",
      setting => 'gpgkey',
    }
    ini_setting {'puppetlabs-dependencies-enabled':
      section => 'puppetlabs-deps',
      value   => '1',
      setting => 'enabled',
    }
    ini_setting {'puppetlabs-dependencies-baseurl':
      section => 'puppetlabs-deps',
      value   => "${mirror}/packages/yum/${ostype}/${::operatingsystemmajrelease}/dependencies/\$basearch",
      setting => 'baseurl',
    }
    ini_setting {'puppetlabs-dependencies-priority':
      section => 'puppetlabs-deps',
      value   => $priority,
      setting => 'priority',
    }
    ini_setting {'puppetlabs-dependencies-gpgcheck':
      section => 'puppetlabs-deps',
      value   => '1',
      setting => 'gpgcheck',
    }
  } else {
    fail("Unsupported osfamily ${::osfamily}")
  }
}
