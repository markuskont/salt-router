net.ipv4.ip_forward:
  sysctl.present:
    - value: 1
    - config: '/etc/sysctl.conf'

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 0
    - config: '/etc/sysctl.conf'
