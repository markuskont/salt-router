{% set os = grains.os|lower() %}

include:
  - gw.suricata.ethtool

suricata:
  pkgrepo.managed:
    - humanname: OISF suricata stable repository
    - clean_file: True
    {% if grains['os'] == 'Ubuntu' %}
    - ppa: oisf/suricata-stable
    {% elif grains['os'] == 'jessie' %}
    - name: deb http://ppa.launchpad.net/oisf/suricata-stable/{{ os }} {{ codename }} main
    - file: /etc/apt/sources.list.d/oisf-suricata-stable.list
    - keyserver: keyserver.ubuntu.com
    - keyid: 9F6FC9DDB1324714B78062CBD7F87B2966EB736F
    {% endif %}
  pkg.latest:
    - refresh: True
    - pkgs:
      - libhtp1
      - {{pkg}}
  service.running:
    - name: {{pkg}}
    - enable: True
    - watch:
      - /etc/default/suricata
      - /etc/suricata/suricata.yam

#/etc/suricata/suricata.yam:
#  file.managed:
#    - mode: 644
#    - source: salt://files/suricata.jinja
#    - template: jinja
#
#
#/etc/default/suricata:
#  file.managed:
#    - mode: 644
#    - source: salt://files/default.conf
