{% from "gw/firewall/map.jinja" import map with context %}
include:
  - gw.firewall.basic-nat

# Ensure that packets coming from internal network, heading towards forwarded port are properly natted
# otherwise internal connections which rely on forward will not work properly
{% for int_ip, port_conf in map.pillar.portforward.items() %}
  {% for net in map.private %}
nat-internal-portforward-{{net}}-{{int_ip}}:
  iptables.append:
    - chain: POSTROUTING
    - table: nat
    - source: {{net}}
    - destination: {{int_ip}}/32
    - jump: "SNAT"
    - to-source: {{map.ext_ip}}
    - comment: "NAT internal traffic toward portforwarded {{int_ip}}"
    - save: True
    - require:
      - iptables: iptables-nat-chain
  {% endfor %}
  {% for port in port_conf %}
portforward-{{int_ip}}-{{port.ext}}-{{port.int}}:
  iptables.append:
    - chain: PREROUTING
    - table: nat
    - destination: {{map.ext_ip}}/32
    - proto: tcp
    - dport: {{port.ext}}
    - jump: DNAT
    - to-destination: {{int_ip}}:{{port.int}}
    - comment: "Forward external port {{port.ext}} to internal port {{port.int}}"
    - save: True
    - require:
      - iptables: iptables-manipulate-chain
    {% if port.restrictions is defined %}
      {% for restriction in port.restrictions %}
allow-forward-{{restriction}}-{{map.ext_ip}}-{{port.ext}}-{{port.int}}:
  iptables.insert:
    - position: 1
    - chain: external-portforward-allow
    - table: filter
    - proto: tcp
    - source: {{restriction}}
    - destination: {{int_ip}}/32
    - dport: {{port.int|replace('-', ':')}}
    - match: state
    - connstate: NEW
    - comment: "Allow external connection to forwarded port {{port.ext}}, limited to {{restriction}}"
    - jump: ACCEPT
    - require:
      - iptables: external-portforward-allow
      {% endfor %}
    {% else %}
allow-forward-{{map.ext_ip}}-{{port.ext}}-{{port.int}}:
  iptables.insert:
    - position: 1
    - chain: external-portforward-allow
    - table: filter
    - proto: tcp
    - source: '0.0.0.0/0'
    - destination: {{int_ip}}/32
    - dport: {{port.int|replace('-', ':')}}
    - match: state
    - connstate: NEW
    - comment: "Allow external connection to forwarded port {{port.ext}}"
    - jump: ACCEPT
    - require:
      - iptables: external-portforward-allow
    {% endif %}
  {% endfor %}
{% endfor %}
