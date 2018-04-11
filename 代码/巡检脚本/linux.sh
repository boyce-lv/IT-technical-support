#! /bin/bash

#check filesystem
touch cfs-`date +%F`.txt
cfs1=`df -h | sed 1d | awk '{print $5}' |cut -d "%" -f 1`
cfs2=`df -i | sed 1d | awk '{print $5}' |cut -d "%" -f 1`
cfs3_1=`df | sed 1d | awk '{print $6}' | wc -l`
cfs3_2=`cat /etc/fstab | grep -v \# | sed 1d | awk '{print $2}' | wc -l`
#check file system usage
if [ $cfs1 -gt 70 ];then
	echo "文件系统使用率不正常" > cfs-`date +%F`.txt
else
	echo "文件系统使用率正常" > cfs-`date +%F`.txt
fi
#check i usage
if [ $cfs2 -gt 70 ];then
	echo "文件系统i节点使用率不正常" >> cfs-`date +%F`.txt
else
	echo "文件系统i节点使用率正常" >> cfs-`date +%F`.txt
fi
#check file system mount
if [ $cfs3_1 -ge $cfs_2 ];then
	echo "文件系统挂载正常" >> cfs-`date +%F`.txt
else 
	echo "文件系统挂载不正常" >> cfs-`date +%F`.txt
fi

#check process
touch cpr-`date +%F`.txt
pid1=`ps -ef | grep defunc | awk '{print $10}'`
pid2=`ps -ef |grep patrolagent |wc -l`
pid3=`ps -ef|grep ntpd |wc -l`
uid=`ps -ef |awk '{print $1,$2}' |grep '\<1\>' | awk '{print $1}'`
#check defunc
if [ $pid1 = defunc ];then
	echo "存在僵尸进程" > cpr-`date +%F`.txt
else
	echo "不存在僵尸进程" >> cpr-`date +%F`.txt
fi
#check patrolagent
if [ $pid2 = 1 ];then
	echo "patrol agent已存在" >> cpr-`date +%F`.txt
else
	echo "patrol agent不存在" >> cpr-`date +%F`.txt
fi
#check ntp
if [ $pid3 = 1 ];then
	echo "nptd已存在" >> cpr-`date +%F`.txt
else
	echo "nptd不存在" >> cpr-`date +%F`.txt
fi
#check uid
if [ $uid = root ]|[ $uid = oracle ]|[ $uid = informix ]|[ $uid = patrol ];then
	echo "父进程为1的用户正常" >> cpr-`date +%F`.txt
else
	echo "父进程为1的用户不正常" >> cpr-`date +%F`.txt
fi

#check errorlog
touch errl-`date +%F`.txt
errl=`cat /var/log/messages |grep -iE "fail|error|fatal|critical"`
if [ -n $errl ];then
	echo "日志中有报错信息--正常" > errl-`date +%F`.txt
else
	echo "日志中没有报错信息--不正常" >> errl-`date +%F`.txt
fi

#check Swap
touch frs-`date +%F`.txt
fst=`free |grep "Swap" |awk '{print $2}'`
fsu=`free |grep "Swap" |awk '{print $3}'`
ra=$(($fsu/$fst*100))
if [ $ra -le 30 ];then
	echo "交换空间使用率正常" > frs-`date +%F`.txt
else
	echo "交换空间使用率不正常" > frs-`date +%F`.txt
fi

#check network
touch ntw-`date +%F`.txt
v_num1=`netstat -in |grep -v "Iface" |grep -iE "eth|bond" |awk '{ print $5 }'|awk '{size+=$1}END{print size}'`
v_num2=`netstat -in |grep -v "Iface" |grep -iE "eth|bond" |awk '{ print $9 }'|awk '{size+=$1}END{print size}'`
chr=`cat /etc/hosts |grep 127.0.0.1|wc -l`
c_LISTEN=`netstat -an|grep "^tcp" |awk '{print $6}'|sort -ir|uniq -c|grep LISTEN |awk '{print $1}'`
c_ESTABLISHED=`netstat -an|grep "^tcp" |awk '{print $6}'|sort -ir|uniq -c|grep ESTABLISHED |awk '{print $1}'`
c_CLOSE_WAIT=`netstat -an|grep "^tcp" |awk '{print $6}'|sort -ir|uniq -c|grep ES    CLOSE_WAIT |awk '{print $1}'`
c_FIN_WAIT_2=`netstat -an|grep "^tcp" |awk '{print $6}'|sort -ir|uniq -c|grep ES    FIN_WAIT_2 |awk '{print $1}'`
cUG=`netstat -rn | grep UG | awk '{print $2}'`
#check network transmission
if [ -z $v_num1 ]&[ -z $v_num2 ];then
	echo "网络传输正常" > ntw-`date +%F`.txt
else
	echo "网络传输不正常" >> ntw-`date +%F`.txt
fi
#check host resolution
if [ $chr = 1 ];then
	echo "loopback/localhost能被解析" >> ntw-`date +%F`.txt
else
	echo "loopback/localhost不能解析" >> ntw-`date +%F`.txt
fi
#check network link number
if [ -n $c_LISTEN ]&[ $c_LISTEN -ge 10 ];then
	echo "LISTEN数量正常" >> ntw-`date +%F`.txt
else
	echo "LISTEN数量不正常" >> ntw-`date +%F`.txt
fi
if [ -n $c_ESTABLISHED ]&[ $c_ESTABLISHED -ge 10 ];then
	echo "ESTABLISHED数量正常" >> ntw-`date +%F`.txt
else
	echo "ESTABLISHED数量不正常" >> ntw-`date +%F`.txt
fi
if [ -n $c_CLOSE_WAIT ]&[ $c_CLOSE_WAIT -le 100 ];then
	echo "CLOSE_WAIT数量正常" >> ntw-`date +%F`.txt
else
	echo "CLOSE_WAIT数量不正常" >> ntw-`date +%F`.txt
fi
if [ -n $c_FIN_WAIT_2 ]&[ $c_FIN_WAIT_2 -le 10 ];then
	echo "FIN_WAIT_2数量正常" >> ntw-`date +%F`.txt
else
	echo "FIN_WAIT_2数量不正常" >> ntw-`date +%F`.txt
fi
#check UG
`ping -c 4 $cUG`
if [ $? -eq 0  ];then
	echo "路由正常" >> ntw-`date +%F`.txt
else
	echo "路由不正常" >> ntw-`date +%F`.txt
fi

#check volume group

#check system security
touch ss-`date +%F`.txt
ss1=`who | wc -l | awk '{print $1}'`
ss2=`awk -F: '$3==0 {print $1}' /etc/passwd |wc -l`
ss3=`find /var/spool/mail -size +64M | wc -l`
#check login user
if [ $ss1 -lt 10 ];then
	echo "同时登陆用户数为$ss1" > ss-`date +%F`.txt
else
	echo "同时登陆用户数过多，为$ss1" > ss-`date +%F`.txt
fi
#check privileged user
if [ $ss2 =1 ];then
	echo "不存在特权用户" >> ss-`date +%F`.txt
else
	echo "存在id为0的非root用户" >> ss-`date +%F`.txt
fi
#check mail log
if [ $ss3 = 1 ];then
	echo "mail日志文件大小正常" >> ss-`date +%F`.txt
else
	echo "mail日志文件大小不正常" >> ss-`date +%F`.txt
fi

#check resources
touch res-`date +%F`.txt
res1=`sar 2 2 | tail -n1 |awk '{print $8}'`
res2=`ps auxwww |sed '1d' |awk '( $3 > 10 ) {print $0}'`
isu=`free |sed -n 3p | awk '{print $3}'`
ist=`free |sed -n 2p | awk '{print $2}'`
res3=`ps auxwww |sed '1d' |awk '( $4 > 20 ) {print $0}'`
#check cpu free
if [ $res1 -ge 30 ];then
	echo "CPU利用率正常" > res-`date +%F`.txt
else
	echo "CPU利用率不正常" > res-`date +%F`.txt
fi
#check the most CPU intensive process
if [ -z $res2 ]|[ $(($res2*100)) -le 30 ];then
	echo "没有CPU占用过高的进程" >> res-`date +%F`.txt
else
	echo "有CPU占用过高的进程" >> res-`date +%F`.txt
fi
#check RAM used
ra=$(($isu/$ist*100))
if [ $ra -lt 70 ];then
	echo "操作系统内存利用率正常" >> res-`date +%F`.txt
else
	echo "操作系统内存利用率不正常" >> res-`date +%F`.txt
fi
#check the most RAM intensive process
if [ -z $res3 ]|[ $(($res3*100)) -le 20 ];then
	echo "没有内存占用过高的进程" >> res-`date +%F`.txt
else
	echo "有内存占用过高的进程" >> res-`date +%F`.txt
fi
