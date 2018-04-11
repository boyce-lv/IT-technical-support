#!/bin/bash
echo "数字计算"
echo "第一个数："
read a
echo "第二个数："
read b
#计算方式第一种,整数
echo "两数相加 `expr $a + $b`"
echo "两数相减 `expr $a - $b`"
echo "两数相乘`expr $a \* $b`"
echo "两数相除 `expr $a / $b`"
echo "取余数 `expr $a % $b`"
#计算方式第二种,可以解决小数问题
echo "$a + $b" | bc
