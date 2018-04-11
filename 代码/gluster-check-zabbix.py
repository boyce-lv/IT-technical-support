#!/bin/python
#coding:utf-8
import os
import re
import commands
#import paramiko
import sys 
class gluster_info:
        def __init__(self,brick_name):
                self.brick_name = brick_name
        def gluster_node_number(self):
                node_number = commands.getstatusoutput("gluster peer status|grep Number|cut -d ' ' -f4")
                gluster_localhost_number = commands.getstatusoutput("ps aux |grep gluster|grep '/usr/sbin/glusterfsd'|grep -v grep | wc -l")
                if gluster_localhost_number > 1:
                        return int(node_number[1]) + 1 
                else:
                        return node_number[1]
        def gluster_status(self):
                brick_status = commands.getstatusoutput("gluster peer status|grep %s -A2|grep Connected|wc -l"%self.brick_name)
                return brick_status[1]
#       def localhost_gluster_status(self):
#               client = paramiko.SSHClient()
#                       client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#                       client.connect("10.133.107.9",username='gluster_zabbix',password='gluster')
#               client.connect(SRC_IP)
#               stdin,stdout,stdeer = client.exec_command("gluster peer status|grep %s -A2|grep Connected|wc -l"%self.brick_name)
#               print stdout.read()
#
#               client.close()
if __name__ == '__main__':
        arg = sys.argv[1]
        res = gluster_info(arg)
#       print node_number 
        node_status = res.gluster_status()
#       node_status_localhost = res1.localhost_gluster_status()
        if arg == "panda-gluster01":
                gluster_localhost_number = commands.getstatusoutput("ps aux |grep gluster|grep '/usr/sbin/glusterfsd'|grep -v grep | wc -l")
                if gluster_localhost_number > 1:
                        print 1
                else:
                        print 0
        if arg == "panda-gluster02":
                node_status = res.gluster_status()
                print node_status
        if arg == "panda-gluster03":
                node_status = res.gluster_status()
                print node_status
        if arg == "node-number":
                node_number = res.gluster_node_number() 
                print node_number
    
