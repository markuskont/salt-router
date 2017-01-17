DEVEL:
  'roles:router':
    - match: grain
    - router
  'roles:firewall':
    - match: grain
    - firewall
  'roles:vpn':
    - match: grain
    - openvpn
