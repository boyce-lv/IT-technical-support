#! /bin/bash
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
