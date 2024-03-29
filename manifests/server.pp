# $Id$
#
# == Class: dns::server
#
# Manage a BIND DNS server
#
# === Parameters
#
# [*dns_master*]
#   DNS master server IP
# [*dns_slaves*]
#   List of DNS slave server IPs
# [*zonedir*] (optional, default=='zones')
#   Subdirectory containing zone files under files/ resource
#
# Note that you must define dns_master and dns_slaves regardless of the
# type of server on which you are using this class.
#
# === Actions
#
# Install & manage appropriate server config and run DNS daemon service
# For a DNS master, install zone resource files
#
# === Requires
#
# Class["dns"]
#
# === Examples
#
# class {'dns::server':
#   dns_master ==> '192.168.0.1',
#   dns_slaves ==> ['10.0.0.1', '10.0.0.2']
# }
#
class dns::server(
  $dns_master,
  $dns_slaves,
  $zonedir = 'zones'
) inherits dns {
  if ($supported == true) {

    if ($::ipaddress == $dns_master) {
      $dnstype = 'master'
    }
    if ($::ipaddress in $dns_slaves) {
      if ($dnstype == 'master') {
        # you're either dom or sub
        fail("${module_name}: ${::hostname} can't be master and slave")
      }
      $dnstype = 'slave'
    }
    if ($dnstype == undef) {
      # ...but you can't just watch
      fail("${module_name}: $::hostname is not a master or slave")
    }

    # master config
    file { $conffile:
      mode    => '0440',
      owner   => 'root',
      group   => 'named',
      content => template("${module_name}/named.conf.erb"),
      notify  => Service[$svc_list],
      require => Package[$pkg_list],
    }
    # common config to masters & slaves
    file { $commonconf:
      owner   => 'root',
      group   => 'named',
      mode    => '0440',
      content => template("${module_name}/named-common.conf.erb"),
      notify  => Service[$svc_list],
      require => Package[$pkg_list],
    }
    # zones config
    file { 'zoneconf':
      name    => "${datadir}/${dnstype}.inc",
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template("${module_name}/zones.inc.erb"),
      require => [ File[$conffile], File[$commonconf] ],
      notify  => Service[$svc_list],
    }

    if ($dnstype == 'master') {
      # copy all zone data to master
      file { 'zones':
        name         => "${datadir}/${dnstype}/",
        owner        => 'root',
        group        => 'named',
        mode         => '0444',
        source       => "puppet:///modules/${module_name}/zones/",
        recurse      => true,
        recurselimit => 1,
        notify       => Service[$svc_list],
      }
    }

    service { $svc_list:
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      subscribe => [ File[$conffile], File[$commonconf], File['zoneconf'] ],
      require   => Package[$pkg_list],
    }

  }
}
