{% set basic_udp = {
  '53': 'DNS',
  '67': 'DHCP',
  '68': 'DHCP',
  '123': 'NTP'
} %}

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
