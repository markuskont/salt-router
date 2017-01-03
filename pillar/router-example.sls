router:
  xenial:
    dhcp:
      manage: true
      authoritive: true
      domain: example.local
      interfaces:
        - enp0s8
      networks:
        192.168.33.0:
          gateway: 192.168.33.1
          subnet: 255.255.255.0
          broadcast: 192.168.33.255
          start: 192.168.33.100
          end: 192.168.33.150
          dns:
            - 8.8.8.8
            - 8.8.4.4
          ntp:
            - 0.europe.pool.ntp.org
          lease:
            default: 86400
            max: 86400
    resolver:
      manage: true
    firewall:
      manage: true
