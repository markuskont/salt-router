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
