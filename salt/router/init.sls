{% set vars = pillar['router'][grains['fqdn']] %}

include:
  - router.sysctl
  {% if vars['dhcp']['manage'] == true %}
  - router.dhcp
  {% endif %}
