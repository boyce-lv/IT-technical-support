#!/bin/bash
#数组的定义，数组名=（元素0 元素1 元素2 ....元素n）
arr1=(1 2 3 4 5 6 7 8 9 10)
arr2=(a b c d e f g h i j)
#数组的调用
echo ${arr1[0]} ${arr1[1]}

#数组全部参数调用
echo ${arr2[@]}
#或
echo ${arr2[*]}
#取消定义的数组
unset arr1
echo ${arr1[0]} ${arr1[1]}

#获取数组的长度
echo "the lenth of arr1 is ${#arr1[@]}"

#取消数组中的元素
unset arr1[0]
echo ${arr1[@]}
echo ${arr1[0]}
echo ${arr1[1]}



