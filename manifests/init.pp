# $Id$
#
# == Class: dns
#
# This is the base class for the DNS server module.
#
# === Parameters:
#
# [*pkg_list*]
#   DNS server (BIND) package names to install
#
# [*svc_list*]
#   DNS server service names to control
#
# [*confdir*]
#   Path to DNS server config files
#
# [*datadir*]
#   Path to DNS resource record files
#
# === Actions:
#
#   Install packages and prepare config and data directories.
#
# === Requires
#
# Class["dns::params"]
#
# === Examples
#
# class {'dns':
#   pkg_list ==> [ 'mybindpkg' ],
#   svc_list ==> [ 'bindsvc' ]
# }
#
class dns(
  $pkg_list = $dns::params::pkg_list,
  $svc_list = $dns::params::svc_list,
  $confdir = $dns::params::confdir,
  $datadir = $dns::params::datadir
) inherits dns::params {
  if ($supported == true) {

    package { $pkg_list:
      ensure => installed,
    }

    file { $confdir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { $datadir:
      ensure => directory,
      owner  => 'root',
      group  => 'named',
      mode   => '0770',
    }

  }
}
