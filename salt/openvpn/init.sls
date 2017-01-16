{% from "openvpn/map.jinja" import map with context %}

install openvpn:
  pkg.installed:
    - pkgs:
       {% for pkg in map.pkgs %}
      - {{pkg }}
      {% endfor %}

/etc/openvpn/server:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

copy rsa:
  file.copy:
    - name: /etc/openvpn/
    - source: /usr/share/easy-rsa
    - makedirs: True
    - force: True
    - subdir: True

{% for dh in map.dh_files %}
openvpn_create_dh_{{ dh }}:
  cmd.run:
    - name: openssl dhparam -out {{ map.conf_dir }}/dh{{ dh }}.pem {{ dh }}
    - creates: {{ map.conf_dir }}/dh{{ dh }}.pem
{% endfor %}

remote_access:
  file.managed:
    - name: /etc/openvpn/remote_access.conf
    - source: salt://openvpn/files/remote_access.jinja
    - template: jinja
    - user: root
    - watch_in:
      - service: install openvpn

rsa_vars:
  file.managed:
    - name: /etc/openvpn/easy-rsa/vars
    - source: salt://openvpn/files/vars.jinja
    - template: jinja
    - user: root
    - watch_in:
      - service: install openvpn

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




#iptabels
