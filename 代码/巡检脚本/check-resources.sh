#! /bin/bash
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
