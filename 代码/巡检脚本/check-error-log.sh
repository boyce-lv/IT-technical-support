#! /bin/bash
#check errorlog
touch errl-`date +%F`.txt
errl=`cat /var/log/messages |grep -iE "fail|error|fatal|critical"`
if [ -n $errl ];then
        echo "日志中有报错信息--正常" > errl-`date +%F`.txt
else
        echo "日志中没有报错信息--不正常" >> errl-`date +%F`.txt
fi
