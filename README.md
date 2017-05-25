# salt-router
Use saltstack to deploy simple Linux gateway boxes.

## suricata

### rule update

Easiest way is to set up oinkmaster cron job on salt master, and to push the rules to relevant minions via Salt state. Nothing fancy.

```
apt-get install oinkmaster
vim /etc/oinkmaster.conf
```

```
url = http://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz
disablesid 2013504
disablesid 2010939
```

Modify schedule and salt file server root as you see fit. You can use rules directory of this repository (gitignore will keep it clean).

```
55 * * * * oinkmaster -C /etc/oinkmaster.conf -o /vagrant/salt/gw/suricata/rules/ && salt -G 'roles:ids' state.apply gw.suricata.rules
```
