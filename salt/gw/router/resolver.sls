bind9:
  pkg.installed:
    - name: bind9
  service.running:
    - enable: true
    - require:
      - pkg: bind9
      - /etc/bind/named.conf.options
    - watch:
      - /etc/bind/named.conf.options

/etc/bind/named.conf.options:
  file.managed:
    - mode: 0644
    - source: salt://router/etc/bind/named.conf.options
