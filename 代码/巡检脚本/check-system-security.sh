#! /bin/bash
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
