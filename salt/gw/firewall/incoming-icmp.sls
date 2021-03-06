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
