include:
  - firewall.incoming-icmp
  - firewall.internal-incoming-udp

# default incoming rules
default-established-traffic:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT
    - save: True
    - comment: "Allow return traffic to local box"

default-input-udp:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - protocol: udp
    - comment: 'Redirect UDP traffic to incoming-udp chain'
    - jump: incoming-udp
    - save: True

default-input-icmp:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - protocol: icmp
    - comment: 'Redirect ICMP traffic to incoming-icmp chain'
    - jump: incoming-icmp
    - save: True

default-localhost:
  iptables.insert:
    - position: 3
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo
    - save: True
    - comment: "Allow loopback interface connections"

default-ssh-input:
  iptables.insert:
    - position: 4
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 22
    - proto: tcp
    - sport: 1025:65535
    - save: True
    - comment: "Allow SSH connections"
