{% from "openvpn/map.jinja" import map with context %}

install openvpn:
  pkg.installed:
    - pkgs:
       {% for pkg in map.pkgs %}
      - {{pkg }}
      {% endfor %}

{{ map.conf_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% for dh in map.dh_files %}
openvpn_create_dh_{{ dh }}:
  cmd.run:
    - name: openssl dhparam -out {{ map.conf_dir }}/dh{{ dh }}.pem {{ dh }}
    - creates: {{ map.conf_dir }}/dh{{ dh }}.pem
{% endfor %}

/etc/openvpn/client-configs/:  #   mkdir /etc/openvpn/client-configs/
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

openvpn_service:
  service.running:
    - name: {{ map.service }}
    - enable: True
    - require:
      - pkg: install openvpn
