{% set vars = pillar['router'][grains['fqdn']]['dhcp'] %}
isc-dhcp-server:
  pkg.latest:
    - name: isc-dhcp-server
  service.running:
    - enable: true
    - watch:
      - /etc/default/isc-dhcp-server
    - require:
      - pkg: isc-dhcp-server
      - /etc/default/isc-dhcp-server

/etc/default/isc-dhcp-server:
  file.managed:
    - mode: 0644
    - source: salt://gw/router/etc/default/isc-dhcp-server
    - template: jinja
    - default:
      interfaces: {{vars['interfaces']}}
    - require:
      - pkg: isc-dhcp-server

/etc/dhcp/dhcpd.conf:
  file.managed:
    - mode: 0644
    - source: salt://gw/router/etc/dhcp/dhcpd.conf
    - template: jinja
    - default:
      domain: {{vars['domain']}}
      authoritive: {{vars['authoritive']}}
      networks: {{vars['networks']}}
