#! /bin/bash
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
