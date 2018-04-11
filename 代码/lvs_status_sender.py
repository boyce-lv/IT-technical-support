#!/usr/bin/env python
#coding=utf-8
#date 2018-03-28
#function:汇报lvs的相关状态,有每秒连接数,每秒转发数,VIP主从切换.每秒转发带宽
#lvs_conns_sec,lvs_packets_sec,keepalived_vip_status
  
import os,commands,sys,time
#变量定义----------------------
#从zabbix_agentd.conf中获取server IP或hostname
zabbix_agent_file='/etc/zabbix/zabbix_agentd.conf'
if not os.path.exists(zabbix_agent_file):
         sys.exit(4)
zabbix_server=commands.getstatusoutput('''grep '^ServerActive' %s|awk -F[=] '{print $2}' '''%zabbix_agent_file)[1].strip()
zabbix_hostname=commands.getstatusoutput('''grep'^Hostname' %s|awk -F[=] '{print $2}' '''%zabbix_agent_file)[1].strip()
if not zabbix_server or not zabbix_hostname:
         sys.exit()
zabbix_server_port=10051
timestamp = int(time.time())
keepalived_vip=['10.133.72.248']  #指定VIP
tmp_file_path='/tmp/lvs_status.txt'   #指定监控值输出文件
#-------------------------
  
  
def monit_lvs():
        #获取每秒包转发数
         status,lvs_packets_sec=commands.getstatusoutput('''tail -1/proc/net/ip_vs_stats | /usr/bin/awk '{print strtonum("0x"$1),strtonum("0x"$2), strtonum("0x"$3), strtonum("0x"$4),strtonum("0x"$5)}'|awk '{print $2}' ''')
  
         #获取每秒转发的流量
         status,lvs_bit_sec=commands.getstatusoutput('''tail -1/proc/net/ip_vs_stats | /usr/bin/awk '{print strtonum("0x"$1),strtonum("0x"$2), strtonum("0x"$3),strtonum("0x"$4), strtonum("0x"$5)}'|awk '{print $4}' ''')
         #获取lvs会话连接数
         status,lvs_conns_sec=commands.getstatusoutput('wc -l/proc/net/ip_vs_conn')
         #获取VIP状态，如值非0为master，为0则是backup，如果有变动，则进行了切换
         status,lvs_keepalived_vip_status=commands.getstatusoutput('/sbin/ip a | grep %s |wc -l'%keepalived_vip[0])
    #如果本机有VIP，则取出VIP的最后一段十进制。
         if int(lvs_keepalived_vip_status) != 0:
                   status,result_ip=commands.getstatusoutput(''' echo%s|awk -F '.' '{print $NF}' '''%keepalived_vip[0])
                   try:
                            lvs_keepalived_vip_status =int(result_ip)
                   except:
                            pass
         #把 key值信息写到一个临时文件,格式为 hostname,key,timestamp,value
         with open(tmp_file_path,'wb') as f:
                   f.write('%s %s %s %s\n'%(zabbix_hostname,'lvs_packets_sec',timestamp,lvs_packets_sec))
                   f.write('%s %s %s %s\n'%(zabbix_hostname,'lvs_bit_sec',timestamp,lvs_bit_sec))
                   f.write('%s %s %s %s\n'%(zabbix_hostname,'lvs_conns_sec',timestamp,lvs_packets_sec))
                   f.write('%s %s %s %s\n'%(zabbix_hostname,'lvs_keepalived_vip_status',timestamp,lvs_keepalived_vip_status))
  
  
if __name__=='__main__':
         monit_lvs()
         #把临时文件通过zabbix_sender命令发送到server端
         send_data_cmd='/usr/bin/zabbix_sender -vv -z %s -p %s -T -i %s'%(zabbix_server,zabbix_server_port,tmp_file_path)
         print (zabbix_server,zabbix_server_port,tmp_file_path)
         os.popen(send_data_cmd)
