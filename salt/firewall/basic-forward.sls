{% from "firewall/map.jinja" import map with context %}
# default forward rules

allow-portforward-chain:
  iptables.chain_present:
    - name: external-portforward-allow

allow-portforward-last-rule:
  iptables.append:
    - chain: external-portforward-allow
    - table: filter
    - jump: RETURN
    - save: True
    - comment: 'Return packet to main forward chain'
    - require:
      - iptables: external-portforward-allow

default-forward-established-traffic:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: FORWARD
    - in-interface: {{grains['ip4_ext']}}
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT
    - save: True
    - comment: "Allow return traffic to local network"

external-portforward-allow-jump:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: FORWARD
    - protocol: tcp
    - comment: 'Redirect TCP traffic to external-portforward-allow chain'
    - jump: external-portforward-allow
    - save: True
    - require:
      - iptables: allow-portforward-chain

{% for net in map.private %}
default-forward-new-traffic-{{net}}:
  iptables.insert:
    - position: 3
    - table: filter
    - chain: FORWARD
    - source: {{net}}
    - out-interface: {{grains['ip4_ext']}}
    - jump: ACCEPT
    - save: True
    - comment: "Allow outgoing traffic from local network {{net}}"
  {% for key, ips in grains['ip4_interfaces'].items() %}
    {% if (key != grains['ip4_ext']) and (key != 'lo') %}
default-forward-self-{{net}}-{{key}}:
  iptables.insert:
    - position: 3
    - table: filter
    - chain: FORWARD
    - source: {{net}}
    - in-interface: {{key}}
    - out-interface: {{key}}
    - jump: ACCEPT
    - save: True
    - comment: "Allow portforward traffic originating from int segment {{net}} behind {{key}}"
    {% endif %}
  {% endfor %}
{% endfor %}
