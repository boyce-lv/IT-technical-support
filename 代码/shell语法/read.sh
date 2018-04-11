#!/bin/bash
read var
echo "you input $var"
#read  -s  输入时隐藏内容
read -s var
echo "you input $var"

#read  -n  5  出入5个字符

read -n 6 var
echo "you input $var"

