default-established-traffic:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT
    - save: True

default-localhost:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo
    - save: True

default-ssh-input:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 22
    - proto: tcp
    - sport: 1025:65535
    - save: True

{% for chain in ['INPUT', 'FORWARD'] %}
deny-{{chain}}-log:
  iptables.append:
    - table: filter
    - chain: {{chain}}
    - jump: LOG
    - log-prefix: "iptables-{{chain}}-dropped: "
    - log-level: 4
    - match: limit
    - limit: 3/min
    - source: '0.0.0.0/0'
    - destination: '0.0.0.0/0'
    - save: True

iptables-{{chain}}-policy:
  iptables.set_policy:
    - chain: {{chain}}
    - policy: DROP
    - save: True
    - require:
      - iptables: default-ssh-input
{% endfor %}
