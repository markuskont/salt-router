
{% if grains.os == 'Ubuntu' %}
  {% set os = grains.os|lower() %}
  {% set codename = grains.oscodename %}
{% elif grains.os == 'Debian' %}
  {% set os = 'ubuntu'%}
  {% if grains.oscodename == 'jessie' %}
    {% set codename = 'vivid' %}
  {% else %}
suricata.fail.codename:
  test.fail_without_changes:
    - name: unsupported Debian version
  {% endif %}
{% else %}
suricata.fail.os:
  test.fail_without_changes:
    - name: unsupported OS
{% endif %}

include:
  - gw.suricata.ethtool

gw.suricata:
  pkgrepo.managed:
    - name: suricata
    - humanname: OISF suricata stable repository
    - clean_file: True
    - name: deb http://ppa.launchpad.net/oisf/suricata-stable/{{ os }} {{ codename }} main
    - file: /etc/apt/sources.list.d/oisf-suricata-stable.list
    - keyserver: keyserver.ubuntu.com
    - keyid: 9F6FC9DDB1324714B78062CBD7F87B2966EB736F
  pkg.latest:
    - name: suricata
    - refresh: True
    - pkgs:
      - libhtp1
      - suricata
  service.running:
    - name: suricata
    - enable: True
    - watch:
      - /etc/default/suricata
      - /etc/suricata/suricata.yam

/etc/suricata/suricata.yam:
  file.managed:
    - mode: 644
    - source: salt://gw/suricata/files/suricata.jinja
    - template: jinja
    - default:
      vars: pillar['router'][grains.fqdn]


/etc/default/suricata:
  file.managed:
    - mode: 644
    - source: salt://gw/suricata/files/default.conf
