# $Id$
#
# == Class: dns::params
#
# Set OS-specific DNS parameters
#
# === Parameters
#
# (none)
#
# === Actions
#
# Define variables based on OS type & release
#
# === Requires
#
# (none)
#
# === Examples
#
# class dns inherits dns::params {
#   ...
# }
#
class dns::params {
  case $::osfamily {
    /(?i-mx:redhat)/: {
      $supported = true
      $pkg_list  = ['bind', 'bind-utils']
      $svc_list  = ['named']
      $confdir   = '/etc'
      $datadir   = '/var/named'
      package { 'jwhois':
        ensure => installed
      }
    }
    /(?i-mx:solaris)/: {
      # this is a guess: UNTESTED
      case $::operatingsystemrelease {
        '5.10': {
          $supported = true
          $pkg_list  = ['SUNWbindr', 'SUNWbind']
        }
        '5.11': {       # inc. OpenSolaris variants
          $supported = true
          $pkg_list  = ['dns/bind']
        }
        default: {
          $supported = false
          warning("${module_name} not supported for ${::operatingsystem} ${::operatingsystemrelease}")
        }
      }
      $svc_list = ['dns/server']
      $confdir  = '/etc'
      $datadir  = '/var/named'
    }
    default: {
      $supported = false
      warning("${module_name} not supported for ${::operatingsystem}")
    }
  }

  # generic settings derived from above
  $conffile = "$confdir/named.conf"
  $commonconf = "$confdir/named-common.conf"
}
