#!/bin/bash
echo "make your choice in 上单 中单 打野"
select var in "上单" "中单" "打野"
do
echo "you select $var"
break
done
echo $var
