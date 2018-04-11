#! /bin/bash
#check swap
touch frs-`date +%F`.txt
fst=`free |grep "Swap" |awk '{print $2}'`
fsu=`free |grep "Swap" |awk '{print $3}'`
ra=$(($fsu/$fst*100))
if [ $ra -le 30 ];then
        echo "交换空间使用率正常" > frs-`date +%F`.txt
else
        echo "交换空间使用率不正常" > frs-`date +%F`.txt
fi
