{% from "firewall/map.jinja" import map with context %}
include:
  - firewall.incoming-icmp
  - firewall.internal-incoming-udp
  - firewall.basic-nat
  - firewall.basic-input
  - firewall.basic-forward
  {% if map.pillar.portforward %}
  - firewall.external-portforward
  {% endif %}
  - firewall.default-policy
