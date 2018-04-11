#!/bin/bash
read a
if [ $a -le 20 -a $a -gt 0 ]
then
	echo "我是小鲜肉"
elif [ $a -gt 20 ] && [ $a -le 50 ]
then
	echo "fighting!"
elif [ $a -gt 50 ]
then
	echo "xiyanghong"
else
	echo "please input a number"
fi
