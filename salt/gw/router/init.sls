{% set vars = pillar['router'][grains['fqdn']] %}

include:
  - router.sysctl
  {% if vars['dhcp']['manage'] == true %}
  - router.dhcp
  {% endif %}
  {% if vars['dns']['manage'] == true %}
  - router.resolver
  {% endif %}
