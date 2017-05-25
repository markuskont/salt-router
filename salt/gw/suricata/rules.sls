/etc/suricata/rules:
  file.recurse:
    - source: salt://gw/suricata/rules/

# NOTE! this is how you are supposed to do it
# I simply had issues with unix-socket and reload-rules (it froze) on debian jessie
# and the deployed systems are low prio
# so service restart is good enough

#gw.suricata.reload-rules:
#  cmd.run:
#    - name: suricatasc -c 'reload-rules'
#    - onchanges:
#      - file: /etc/suricata/rules

gw.suricata.reload-rules:
  cmd.run:
    - name: service suricata restart
    - onchanges:
      - file: /etc/suricata/rules
