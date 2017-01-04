{% set inc_icmp_rate_min = 90 %}

# create chains here
iptables-incoming-icmp-chain-ipv4:
  iptables.chain_present:
    - name: incoming-icmp

{% for icmp_msg_num, icmp_msg_text in {
    '0': 'echo-reply',
    '3/1': 'destination-unreachable/host-unreachable',
    '3/3': 'destination-unreachable/port-unreachable',
    '3/4': 'destination-unreachable/fragmentation-needed',
    '8': 'echo-request',
    '11': 'time-exceeded',
  }.items() %}
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
{% endfor %}

iptables-incoming-icmp-chain-log-reject-ipv4:
  iptables.append:
    - chain: incoming-icmp
    - match:
      - comment
    - comment: 'iptables.icmp: Log before rejecting'
    - jump: LOG
    - log-prefix: "iptables-incoming-icmp-rejected: "
    - log-level: 4
    - match: limit
    - limit: 3/min
    - source: '0.0.0.0/0'
    - destination: '0.0.0.0/0'

iptables-incoming-icmp-chain-last-rule-ipv4:
  iptables.append:
    - chain: incoming-icmp
    - match:
      - comment
    - comment: 'iptables.icmp: Reject the rest'
    - jump: REJECT
    - order: last
    - require:
      - iptables: iptables-incoming-icmp-chain-log-reject-ipv4

# default incoming rules
default-established-traffic:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT
    - save: True
    - comment: "000 - Allow return traffic from local box"

default-input-icmp:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - protocol: icmp
    - jump: incoming-icmp
    - save: True

default-localhost:
  iptables.insert:
    - position: 3
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: 127.0.0.1
    - save: True
    - comment: "001 - allow loopback interface connections"

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
