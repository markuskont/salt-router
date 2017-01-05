#!/usr/bin/env python

import salt.modules.network

def internal_interfaces():

    grains = {}

    internalips = salt.modules.network.ip_addrs(cidr='10.0.0.0/8')
    interfaces = salt.modules.network.interfaces()

    grains['internal_interfaces'] = []

    for interface, data in interfaces.iteritems():
        for internalip in internalips:
            if 'inet' in data and data['inet'][0]['address'] and data['inet'][0]['address'] == internalip:
                grains['internal_interfaces'].append(interface)

    return grains
