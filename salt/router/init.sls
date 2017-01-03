{% set vars = pillar['router'][grains['fqdn']] %}

include:
  - router.sysctl
  - router.firewall
  {% if vars['dhcp']['manage'] == true %}
  - router.dhcp
  {% endif %}
  {% if vars['dns']['manage'] == true %}
  - router.resolver
  {% endif %}
