{% from "gw/firewall/map.jinja" import map with context %}
include:
  - gw.firewall.incoming-icmp
  - gw.firewall.internal-incoming-udp
  - gw.firewall.basic-nat
  - gw.firewall.basic-input
  - gw.firewall.basic-forward
  {% if 'portforward' in map.pillar %}
  - gw.firewall.external-portforward
  {% endif %}
  - gw.firewall.default-policy
