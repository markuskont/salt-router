{% from "gw/firewall/map.jinja" import map with context %}
# create nat filter and basic rules
# POSTROUTING chain
iptables-nat-chain:
  iptables.chain_present:
    - name: POSTROUTING
    - table: nat

iptables-manipulate-chain:
  iptables.chain_present:
    - name: PREROUTING
    - table: nat

{% for net in map.private %}
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
