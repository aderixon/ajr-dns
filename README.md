# Summary

This is a Puppet module to control DNS services via BIND. The zones are
autoconfigured from the available RR files.

This module currently supports *EL-derived distributions and (untested)
recent Solaris variants.

# Usage

1. Install the module in your modulepath.
2. Drop your zone data files into the `files/zones/` directory, one per
zone and each named *domain*.db. Each file should contain resource records
in standard BIND format.
3. Define the class on each master and slave node, specifying the local IP
of the master *and* slave(s) each time:

    class {'dns::server':
      dns_master => '192.168.0.1',
      dns_slaves => ['10.0.0.1', '10.0.0.2']
    }
