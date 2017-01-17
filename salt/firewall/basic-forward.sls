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

{% for net in map.private %}
default-forward-new-traffic-{{net}}:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: FORWARD
    - source: {{net}}
    - out-interface: {{grains['ip4_ext']}}
    - jump: ACCEPT
    - save: True
    - comment: "Allow outgoing traffic from local network {{net}}"
{% endfor %}