router:
  xenial-r1:
    dhcp:
      manage: true
      authoritive: true
      domain: example.local
      interfaces:
        - enp0s8
      networks:
        192.168.1.0:
          gateway: 192.168.1.1
          subnet: 255.255.255.0
          broadcast: 192.168.1.255
          start: 192.168.1.100
          end: 192.168.1.150
          dns:
            - 8.8.8.8
            - 8.8.4.4
          ntp:
            - 0.europe.pool.ntp.org
          lease:
            default: 86400
            max: 86400
    dns:
      manage: true

firewall:
  xenial-r1:
    manage: true
    portforward:
      192.168.1.90:
        - ext: 2180
          int: 80
        - ext: 554
          int: 554
        - ext: 8000
          int: 8000
        - ext: 60000:60100
          int: 60000-60100
      192.168.1.91:
        - ext: 33893
          int: 3389
          restrictions:
            - 1.2.3.4/32
            - 3.4.5.0/24
