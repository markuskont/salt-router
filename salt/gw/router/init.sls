{% set vars = pillar['router'][grains['fqdn']] %}

include:
  - gw.router.sysctl
  {% if vars['dhcp']['manage'] == true %}
  - gw.router.dhcp
  {% endif %}
  {% if vars['dns']['manage'] == true %}
  - gw.router.resolver
  {% endif %}
