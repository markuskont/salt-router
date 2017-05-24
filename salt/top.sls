DEVEL:
  'roles:router':
    - match: grain
    - gw.router
  'roles:firewall':
    - match: grain
    - gw.firewall
  'roles:vpn':
    - match: grain
    - gw.openvpn
  'roles:ids':
    - match: grains
    - gw.suricata
