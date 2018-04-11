#!/bin/bash
echo "please input man or woman"
read a
if [ $a = man ];then
	echo "you are man"
elif [ $a = woman ];then
	echo "you are woman"
else
	echo "who are you ?"
fi
