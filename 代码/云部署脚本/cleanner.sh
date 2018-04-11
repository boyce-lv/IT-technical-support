#!/bin/bash

a=(`yum history | grep Install | awk '{print $1}'`)
yum history undo ${a[*]} -y
rm -fr /etc/my.cnf* /etc/keytone /etc/nova /etc/glance /etc/neutron /etc/cinder /var/lib/mysql
