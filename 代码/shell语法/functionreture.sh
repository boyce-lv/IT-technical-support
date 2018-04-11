#!/bin/bash
turn(){
echo "get sum of two number"
echo "please input a number :"
read m
echo "please input another number :"
read n
return $(($m+$n))
#x=$(($m+$n))
#echo $x
}
turn
echo $?
