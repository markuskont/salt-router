{% set inc_icmp_rate_min = 90 %}
{% set acceptable_icmp = {
    '0': 'echo-reply',
    '3/1': 'destination-unreachable/host-unreachable',
    '3/3': 'destination-unreachable/port-unreachable',
    '3/4': 'destination-unreachable/fragmentation-needed',
    '8': 'echo-request',
    '11': 'time-exceeded',
  }
%}
{% set private = ['192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12'] %}
{% set basic_udp = {
  '53': 'DNS',
  '67': 'DHCP',
  '68': 'DHCP',
  '123': 'NTP'
} %}
# create incoming icmp chain
iptables-incoming-icmp-chain-ipv4:
  iptables.chain_present:
    - name: incoming-icmp

{% for icmp_msg_num, icmp_msg_text in acceptable_icmp.items() %}
iptables-allow-incoming-icmp-{{ icmp_msg_text }}:
  iptables.append:
    - table: filter
    - chain: incoming-icmp
    - family: ipv4
    - match:
      - icmp
      - comment
      - limit
    - protocol: icmp
    - icmp-type: {{ icmp_msg_num }}
    - comment: "iptables-ipv4: Allow incoming {{ icmp_msg_text }}"
    - limit: {{inc_icmp_rate_min}}/min
    - jump: ACCEPT
    - save: True
{% endfor %}

iptables-incoming-icmp-chain-log-reject-ipv4:
  iptables.append:
    - chain: incoming-icmp
    - table: filter
    - match:
      - comment
    - comment: 'iptables.icmp: Log before rejecting'
    - jump: LOG
    - log-prefix: "iptables-inc-icmp-rej: "
    - log-level: 4
    - match: limit
    - limit: 3/min
    - source: '0.0.0.0/0'
    - destination: '0.0.0.0/0'
    - save: True

iptables-incoming-icmp-chain-last-rule-ipv4:
  iptables.append:
    - chain: incoming-icmp
    - table: filter
    - match:
      - comment
    - comment: 'iptables.icmp: Reject the rest'
    - jump: REJECT
    - order: last
    - save: True
    - require:
      - iptables: iptables-incoming-icmp-chain-log-reject-ipv4

# create incoming udp chain and basic rules
incoming-udp-chain:
  iptables.chain_present:
    - name: incoming-udp
    - table: filter

incoming-udp-last-rule:
  iptables.append:
    - chain: incoming-udp
    - table: filter
    - jump: RETURN
    - save: True
    - comment: 'Return packet to main input chain'
    - require:
      - iptables: incoming-udp-chain

# allow basic services from internal interfaces
{% for interface, addrs in grains['ip4_interfaces'].items() %}
  {% if (interface != grains['ip4_ext']) and (interface != 'lo')  %}
    {% for port, comment in basic_udp.items() %}
incoming-udp-{{interface}}-{{port}}:
  iptables.insert:
    - position: 1
    - chain: incoming-udp
    - table: filter
    - proto: udp
    - dport: {{port}}
    - in-interface: {{interface}}
    - comment: {{comment}}
    - jump: ACCEPT
    - save: True
    - require:
      - iptables: incoming-udp-chain
      - iptables: incoming-udp-last-rule
    {% endfor %}
  {% endif %}
{% endfor %}

# create nat filter and basic rules
# POSTROUTING chain
iptables-nat-chain:
  iptables.chain_present:
    - name: POSTROUTING
    - table: nat

{% for net in private %}
nat-outgoing-traffic-{{net}}:
  iptables.append:
    - chain: POSTROUTING
    - table: nat
    - source: {{net}}
    - out-interface: {{grains['ip4_ext']}}
    - comment: "NAT outgoing traffic from private network"
    - jump: "MASQUERADE"
    - require:
      - iptables: iptables-nat-chain
{% endfor %}


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

# default forward rules
default-forward-established-traffic:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: FORWARD
    - in-interface: {{grains['ip4_ext']}}
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT
    - save: True
    - comment: "Allow return traffic to local network"

{% for net in private %}
default-forward-new-traffic-{{net}}:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: FORWARD
    - source: {{net}}
    - out-interface: {{grains['ip4_ext']}}
    - jump: ACCEPT
    - save: True
    - comment: "Allow outgoing traffic from local network {{net}}"
{% endfor %}

# Final log and drop
# We shall not be using ipv6, so only drop
{% for chain in ['INPUT', 'FORWARD'] %}
  {% for family in ['ipv4', 'ipv6'] %}
deny-{{family}}-{{chain}}-log:
  iptables.append:
    - table: filter
    - chain: {{chain}}
    - jump: LOG
    - log-prefix: "iptables-{{family}}-{{chain}}-dropped: "
    - log-level: 4
    - match: limit
    - limit: 3/min
    - source: '0.0.0.0/0'
    - destination: '0.0.0.0/0'
    - family: {{family}}
    - save: True
    - order: last

iptables-{{family}}-{{chain}}-policy:
  iptables.set_policy:
    - chain: {{chain}}
    - policy: DROP
    - save: True
    - family: {{family}}
    - require:
      - iptables: default-ssh-input
  {% endfor %}
{% endfor %}
